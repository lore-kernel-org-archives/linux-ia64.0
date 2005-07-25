From: Keith Owens <kaos@sgi.com>
Date: Mon, 25 Jul 2005 05:29:12 +0000
Subject: Backtrace problems from a signal handler
Message-Id: <13701.1122269352@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

gdb with libunwind support does not unwind correctly if a signal
handler calls another function which then takes a core dump.

SuSE SLES9 SP2.  gdb-6.3-16.4.  libunwind-0.98.5-3.2.  gcc 3.3.3.

% cat signal-test.c
#include <signal.h>

void foo(void)
{
	*(char *)0 = 1;
}

static void handler(int sig)
{
	foo();
}

int main(void)
{
	signal(SIGALRM, handler);
	kill(0, SIGALRM);
	return 0;
}

% make CFLAGS="-Wall -g" signal-test
% ulimit -c unlimited
% ./signal-test
% gdb signal-test core
(gdb) bt
#0  foo () at signal-test.c:5
#1  0x40000000000006e0 in handler (sig) at signal-test.c:10
#2  <signal handler called>
Previous frame inner to this frame (corrupt stack?)

Running under gdb and setting a breakpoint on foo() has exactly the
same problem.  IOW, this is not being caused by the core dump, it is
purely an unwind problem.

If the handler does '*(char *)0 = 1;' directly instead of calling foo()
then the backtrace works.

(gdb) bt
#0  handler (sig) at signal-test.c:10
#1  <signal handler called>
#2  0xa000000000010640 in ?? ()
#3  0x20000000000a8a80 in kill () from /lib/tls/libc.so.6.1
#4  0x4000000000000780 in main () at signal-test.c:17

This problem tends to be reported against abort() because that is
usually the function that starts the core dump, but my tests show that
abort() is innocent.  Calling any function from a signal handler stuffs
up the backtrace.

