From: Keith Owens <kaos@sgi.com>
Date: Tue, 24 Feb 2004 12:05:37 +0000
Subject: 2.6.3 Heisenbug in unwind.c
Message-Id: <2654.1077624337@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I am seeing a Heisenbug in the 2.6.3 kernel unwind code.  The symptoms
are that the backtrace terminates early, usually failing to unwind past
an interrupt frame.  Andreas, this _may_ be what you are seeing.

Changing the config options (sn2->dig) makes backtrace work again.
Turning on UNW_DEBUG to debug the unwinder makes backtrace work again :(.
Adding 30 dummy functions (which only call printk and are never called
themselves) to unwind.c makes the backtrace work again.

That last one really worries me.  All it does is shift the position of
the real unwind code within the kernel without changing the unwind code
itself.  Looks like an uninitialised pointer somewhere.

gcc version 3.2.3 20030502 (Red Hat Linux 3.2.3-24)
GNU assembler version 2.14.90.0.4 (ia64-unknown-linux-gnu) using BFD version 2.14.90.0.4 20030523

