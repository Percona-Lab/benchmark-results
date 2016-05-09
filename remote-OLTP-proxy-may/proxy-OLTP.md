MySQL 5.7 - proxy overhead
==========================

Setup
-----

-   Client (sysbench) and server are on different servers, connected via 10Gb network.
-   CPU: 56 logical CPU threads servers Intel(R) Xeon(R) CPU E5-2683 v3 @ 2.00GHz
-   sysbench 10 tables x 10mln rows, pareto distribution
-   OS: Ubuntu 15.10 (Wily Werewolf)
-   Kernel 4.2.0-30-generic

-   MaxScale 1.4.1 - self compiled

Results
-------

![](proxy-OLTP_files/figure-markdown_github/proxysql-1.png)

![](proxy-OLTP_files/figure-markdown_github/proxysql-ff-1.png)

![](proxy-OLTP_files/figure-markdown_github/proxysql-maxscale-1.png)

![](proxy-OLTP_files/figure-markdown_github/proxysql-maxscale-16thr-1.png)

![](proxy-OLTP_files/figure-markdown_github/test-1.png)

### Relative performance

base value: MySQL 5.7

![](proxy-OLTP_files/figure-markdown_github/schema-relative-2-1.png)
