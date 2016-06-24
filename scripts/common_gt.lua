-- Input parameters
-- oltp-tables-count - number of tables to create
-- oltp-secondary - use secondary key instead PRIMARY key for id column
--
--

function create_insert(table_id)

   local index_name
   local i
   local j
   local query

   if (oltp_secondary) then
     index_name = "KEY xid"
   else
     index_name = "PRIMARY KEY"
   end

   i = table_id

   print("Creating table 'sbtest" .. oltp_suffix .. i .. "'...")
   if (db_driver == "mysql") then
      query = [[
CREATE TABLE sbtest]] .. oltp_suffix .. i .. [[ (
id INTEGER UNSIGNED NOT NULL ]] ..
((oltp_auto_inc and "AUTO_INCREMENT") or "") .. [[,
k INTEGER UNSIGNED DEFAULT '0' NOT NULL,
c CHAR(120) DEFAULT '' NOT NULL,
pad CHAR(60) DEFAULT '' NOT NULL,
]] .. index_name .. [[ (id)
) TABLESPACE ts]] .. oltp_db_id [[/*! ENGINE = ]] .. mysql_table_engine ..
" MAX_ROWS = " .. myisam_max_rows .. " */"

   elseif (db_driver == "pgsql") then
      query = [[
CREATE TABLE sbtest]] .. i .. [[ (
id SERIAL NOT NULL,
k INTEGER DEFAULT '0' NOT NULL,
c CHAR(120) DEFAULT '' NOT NULL,
pad CHAR(60) DEFAULT '' NOT NULL,
]] .. index_name .. [[ (id)
) ]]

   elseif (db_driver == "drizzle") then
      query = [[
CREATE TABLE sbtest (
id INTEGER NOT NULL ]] .. ((oltp_auto_inc and "AUTO_INCREMENT") or "") .. [[,
k INTEGER DEFAULT '0' NOT NULL,
c CHAR(120) DEFAULT '' NOT NULL,
pad CHAR(60) DEFAULT '' NOT NULL,
]] .. index_name .. [[ (id)
) ]]
   else
      print("Unknown database driver: " .. db_driver)
      return 1
   end

--   print ("Generating table sbtest"..i .. "gen_type:" ..gen_type)
   

   local f,f_cre,err
   if (gen_type == "file" ) then
     f_cre,err = io.open(data_path .. "/sbtest" .. oltp_suffix .. i ..".cre", "w")
     if not f_cre then 
             print(err) 
             return 1
     end
     f,err = io.open(data_path .. "/sbtest" .. oltp_suffix .. i ..".txt", "w")
     if not f then 
             print(err) 
             return 1
     end
   end


   if (gen_type == "db" ) then
     if (db_driver == "mysql") then
        db_query("CREATE TABLESPACE ts" .. oltp_db_id " ADD DATAFILE 'ts" .. oltp_db_id .. ".ibd' Engine=InnoDB")
     end
     db_query(query)
     db_query("CREATE INDEX k_" .. i .. " on sbtest" .. oltp_suffix .. i .. "(k)")
   elseif (gen_type == "file" ) then 
     f_cre:write(query..";\n")
     f_cre:write("CREATE INDEX k_" .. i .. " on sbtest" .. oltp_suffix .. i .. "(k);\n")
   end


   print("Inserting " .. oltp_table_size .. " records into 'sbtest" .. oltp_suffix .. i .. "'")

   if (gen_type == "db" ) then

   if (oltp_auto_inc) then
      db_bulk_insert_init("INSERT INTO sbtest" .. oltp_suffix .. i .. "(k, c, pad) VALUES")
   else
      db_bulk_insert_init("INSERT INTO sbtest" .. oltp_suffix .. i .. "(id, k, c, pad) VALUES")
   end
   end

   local c_val
   local pad_val


   for j = 1,oltp_table_size do

   c_val = sb_rand_str([[
###########-###########-###########-###########-###########-###########-###########-###########-###########-###########]])
   pad_val = sb_rand_str([[
###########-###########-###########-###########-###########]])

      if (gen_type == "db" ) then
      if (oltp_auto_inc) then
	 db_bulk_insert_next("(" .. sb_rand(1, oltp_table_size) .. ", '".. c_val .."', '" .. pad_val .. "')")
      else
	 db_bulk_insert_next("("..j.."," .. sb_rand(1, oltp_table_size) .. ",'".. c_val .."', '" .. pad_val .. "'  )")
      end
      elseif (gen_type == "file" ) then
         if (oltp_auto_inc) then
         f:write("NULL," .. sb_rand(1, oltp_table_size) .. ",'".. c_val .."', '" .. pad_val .. "'\n")
         else
         f:write(j.."," .. sb_rand(1, oltp_table_size) .. ",'".. c_val .."', '" .. pad_val .. "'\n")
         end
      end
   end

   if (gen_type == "db" ) then
     db_bulk_insert_done()
   elseif (gen_type == "file" ) then
      f_cre:close()
      f:close()
   end


end


function prepare()
   local query
   local i
   local j

   set_vars()

   if (gen_type == "db" ) then
      db_connect()
   end

   for i = 1,oltp_tables_count do
     create_insert(i)
   end

   return 0
end

function cleanup()
   local i

   set_vars()

   for i = 1,oltp_tables_count do
   print("Dropping table 'sbtest" .. oltp_suffix .. i .. "'...")
   db_query("DROP TABLE sbtest".. oltp_suffix .. i )
   end
end

function set_vars()
   oltp_table_size = oltp_table_size or 10000
   oltp_range_size = oltp_range_size or 100
   oltp_tables_count = oltp_tables_count or 1
   oltp_point_selects = oltp_point_selects or 10
   oltp_simple_ranges = oltp_simple_ranges or 1
   oltp_sum_ranges = oltp_sum_ranges or 1
   oltp_order_ranges = oltp_order_ranges or 1
   oltp_distinct_ranges = oltp_distinct_ranges or 1
   oltp_index_updates = oltp_index_updates or 1
   oltp_non_index_updates = oltp_non_index_updates or 1
   oltp_db_id = oltp_db_id or 0
   oltp_db_count = oltp_db_count or 1

   gen_type='db'

   oltp_high_prio = ''


   if (oltp_high_prio_mode == 'stmt') then 
     oltp_high_prio = 'statements'
   end

   if (oltp_high_prio_mode == 'trx') then 
     oltp_high_prio = 'transactions'
   end

   if (oltp_high_prio_mode == 'none') then 
     oltp_high_prio = 'none'
   end
   
   if (oltp_high_prio_set == ''  or oltp_high_prio_set == nil) then 
     oltp_high_prio_set = 'once'
   end

   --Allows to skip insert and delete statements and execute update_key/no_key individualy

   if (data_gen_type == 'file') then 
     gen_type='file'
   end

   if (gen_type == 'file' and ( data_path == '' or data_path == nil )) then 
      data_path=io.popen"pwd":read'*l'
--      print("Data path: ".. data_path)
   end
   
   if (oltp_suffix == nil ) then 
     oltp_suffix=''
   end

   if (oltp_test_mode == 'nontrx') then 
         oltp_test_mode = false
--         print("NONTRXXXXXXXXXXXX")
   else
      oltp_test_mode=true
   end   

   if (oltp_auto_inc == 'off') then
      oltp_auto_inc = false
   else
      oltp_auto_inc = true
   end

   if (oltp_read_only == 'on') then
      oltp_read_only = true
   else
      oltp_read_only = false
   end

   if (oltp_skip_trx == 'on') then
      oltp_skip_trx = true
   else
      oltp_skip_trx = false
   end

   if (oltp_reconnect == 'on') then
      oltp_reconnect = true
   else
      oltp_reconnect = false
   end
  


end
