From: Mario Smarduch <cms063@email.mot.com>
Date: Fri, 11 Apr 2003 18:17:38 +0000
Subject: [Linux-ia64] gdb problem unwinding abort in signal
Message-Id: <marc-linux-ia64-105590723705468@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

When our application aborts in the signal handler (no altstack
is setup) the stack backtrace  discontinues at the signal
handler.

(gdb) where
#0  0x20000000000a6342 in kill () at soinit.c:56
#1  0x20000000000a61f0 in raise (sig=6) at ../sysdeps/posix/raise.c:27
#2  0x20000000000a8a70 in abort () at ../sysdeps/generic/abort.c:88
#3  0x4000000000000910 in sig_report_and_die ()


Manually unwinding the stack shows  the rp set
to ia64_sigtramp(). The privilaged
gate page simplifies allot of things,  but it poses a problem
to our software because we send events for
all signals of importance, and count on the core dump
to capture the full call trace prior to and including the
signal - gdb displays this full backtrace on all other
architectures we run on.

If this is the problem how does one get around it
besides manually unwinding the stack?

- mario.




