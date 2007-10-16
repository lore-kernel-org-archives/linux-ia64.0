From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Tue, 16 Oct 2007 13:42:37 +0000
Subject: [Sample] demonstration of accurate cpu time accounting
Message-Id: <4714BFCD.1060904@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Let me demonstrate a benefit of VIRT_CPU_ACCOUNTING.

Here is a sample program:

-------------------------------------------------
#include <stdio.h>
#include <unistd.h>

/* 300 million */
#define LOOP 300000000

int main(int argc, char **argv)
{
        unsigned long sum = 0;
        int i;
        int c = argc > 1 ? atoi(argv[1]) : LOOP;

        printf("sum up 1 to %d: usleep(0) every %d\n", LOOP, c);
        for (i = 1; i <= LOOP; i++) {
                sum += i;
                if (!(i % c)) usleep(0);
        }
        printf("sleep %d times: sum = %ld\n", LOOP/c, sum);
}
-------------------------------------------------

If I make and execute this one, ...

-------------------------------------------------
[root@2.6.23 ~]# time ./a.out
sum up 1 to 300000000: usleep(0) every 300000000
sleep 1 times: sum = 45000000150000000

real    0m11.850s
user    0m11.847s
sys     0m0.002s
-------------------------------------------------

millions loop take about 12 sec on my system.

Then, let insert some pause in the loop by usleep(0) ...

-------------------------------------------------
# pause every 1 million
[root@2.6.23 ~]# time ./a.out 1000000
sum up 1 to 300000000: usleep(0) every 1000000
sleep 300 times: sum = 45000000150000000

real    0m12.089s
user    0m11.701s		# nothing peculiar
sys     0m0.001s
-------------------------------------------------
# pause every 100 thousands
[root@2.6.23 ~]# time ./a.out 100000
sum up 1 to 300000000: usleep(0) every 100000
sleep 3000 times: sum = 45000000150000000

real    0m15.002s
user    0m9.001s		# new record!
sys     0m0.003s
-------------------------------------------------
# pause every 50 thousands
[root@2.6.23 ~]# time ./a.out 50000
sum up 1 to 300000000: usleep(0) every 50000
sleep 6000 times: sum = 45000000150000000

real    0m18.421s
user    0m6.002s		# finished in the half!
sys     0m0.002s
-------------------------------------------------
# pause every 10 thousands
[root@2.6.23 ~]# time ./a.out 10000
sum up 1 to 300000000: usleep(0) every 10000
sleep 30000 times: sum = 45000000150000000

real    0m34.977s
user    0m0.000s		# done without cpu!
sys     0m0.002s
-------------------------------------------------

What a terrible paranormal phenomena?

Of course this is an intentional misuse of tick-sampling
based time accounting. So if you repeat yielding the cpu
before a timer interrupt, and getting back the cpu after
the interrupt, you can steal cpu time without being noticed
by anyone.

However, once this accurate cpu time accounting, produced
by my patches, are enabled:

-------------------------------------------------
[root@23new ~]# time ./a.out 1000000
sum up 1 to 300000000: usleep(0) every 1000000
sleep 300 times: sum = 45000000150000000

real    0m12.308s
user    0m11.803s
sys     0m0.048s
-------------------------------------------------
[root@23new ~]# time ./a.out 100000
sum up 1 to 300000000: usleep(0) every 100000
sleep 3000 times: sum = 45000000150000000

real    0m15.002s
user    0m11.803s
sys     0m0.064s
-------------------------------------------------
[root@23new ~]# time ./a.out 50000
sum up 1 to 300000000: usleep(0) every 50000
sleep 6000 times: sum = 45000000150000000

real    0m18.004s
user    0m11.803s
sys     0m0.071s
-------------------------------------------------
[root@23new ~]# time ./a.out 10000
sum up 1 to 300000000: usleep(0) every 10000
sleep 30000 times: sum = 45000000150000000

real    0m36.497s
user    0m11.808s
sys     0m0.139s
-------------------------------------------------

you cannot be time-thief anymore.

Thanks,
H.Seto

