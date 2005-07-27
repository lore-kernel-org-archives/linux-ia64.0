From: Keith Owens <kaos@sgi.com>
Date: Wed, 27 Jul 2005 01:09:58 +0000
Subject: Re: Backtrace problems from a signal handler
Message-Id: <4459.1122426598@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <13701.1122269352@kao2.melbourne.sgi.com>
In-Reply-To: <13701.1122269352@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 25 Jul 2005 15:29:12 +1000, 
Keith Owens <kaos@sgi.com> wrote:
>gdb with libunwind support does not unwind correctly if a signal
>handler calls another function which then takes a core dump.
>
>SuSE SLES9 SP2.  gdb-6.3-16.4.  libunwind-0.98.5-3.2.  gcc 3.3.3.

David Mosberger suggested checking the CVS version of gdb.  The
gdb-6.3.50.20050726 snapshot handles backtrace through a signal
handler when the handler calls another function.

Program received signal SIGABRT, Aborted.
0xa000000000010641 in __kernel_syscall_via_break ()
(gdb) bt
#0  0xa000000000010641 in __kernel_syscall_via_break ()
#1  0x20000000000a8690 in raise () from /lib/tls/libc.so.6.1
#2  0x20000000000aadf0 in abort () from /lib/tls/libc.so.6.1
#3  0x4000000000000740 in foo () at signal-test.c:6
#4  0x4000000000000780 in handler (sig) at signal-test.c:12
#5  <signal handler called>
#6  0xa000000000010640 in __kernel_syscall_via_break ()
#7  0x20000000000a8a80 in kill () from /lib/tls/libc.so.6.1
#8  0x4000000000000810 in main () at signal-test.c:18

