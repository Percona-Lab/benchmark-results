cat $1 | awk -F ',' -v extra=$2 '{
        f1=""
        for(i=1; i<=NF; i++) {
                tmp=match($i, /\[[[:space:]]*(.*)s\]/,a)
                if(tmp) {
                        f1=a[1]
                }
                tmp=match($i, /[[:space:]]*threads:[[:space:]]+(.*)/,b)
                if(tmp) {
                        threads=b[1]
                }
                tmp=match($i, /[[:space:]]*tps:[[:space:]]+(.*)/,b)
                if(tmp) {
                        tps=b[1]
                }
                tmp=match($i, /[[:space:]]*reads:[[:space:]]+(.*)/,b)
                if(tmp) {
                        reads=b[1]
                }
                tmp=match($i, /[[:space:]]*writes:[[:space:]]+(.*)/,b)
                if(tmp) {
                        writes=b[1]
                }
                tmp=match($i, /[[:space:]]*response time:[[:space:]]+(.*)(m|u)s/,b)
                if(tmp) {
                        f3=b[1]
                }
        }
        if (f1) 
        print f1","threads","tps","reads","writes","f3","extra
}' >> $3
