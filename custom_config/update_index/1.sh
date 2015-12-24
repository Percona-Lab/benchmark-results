
cat $1 | awk -F ',' '{
	f1=""
        for(i=1; i<=NF; i++) {
                tmp=match($i, /\[[[:space:]]*(.*)s\]/,a)
                if(tmp) {
                        f1=a[1]
                }
                tmp=match($i, /[[:space:]]*writes:[[:space:]]+(.*)/,b)
                if(tmp) {
                        f2=b[1]
                }
        }
	if (f1) 
	print bench","size","workload","f1","f2
}' bench=$2 size=$3 workload=$4
