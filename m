From: Randolph Chung <randolph@tausq.org>
Date: Sun, 24 Feb 2002 03:10:30 +0000
Subject: [Linux-ia64] gcc profiling broken on Linux/ia64?
Message-Id: <marc-linux-ia64-105590701905185@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Greetings....

I was wondering if anyone has gotten gcc profiling to work on 
linux/ia64?

$ cat hello.c 
int main(int argc, char **argv) { return 0; }
$ gcc -pg -o hello hello.c
$ ./hello
Segmentation fault

I've tried this with the 2.96 compilers on RedHat 7.2 as well as both
2.96 and 3.0.4 compilers on Debian 3.0 (glibc 2.2.4 on RH, 2.2.5 on
Debian)

Backtrace with gdb looks like this:

(gdb) bt
#0  __mcount (frompc140901064496364080, selfpcF11686018427390128)
    at mcount.c:96
#1  0x20000000001fdf30 in mcount () at soinit.c:56
#2  0x40000000000008b0 in main (argc73766400, argv=0x7000a1000005501)
    at hello.c:1

mcount.c:96         toindex = *frompcindex;

(gdb) print frompcindex
$1 = (u_short *) 0xa000000000471ce8

Any pointers would be much appreciated.

randolph

