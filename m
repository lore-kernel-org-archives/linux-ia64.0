From: Keith Owens <kaos@melbourne.sgi.com>
Date: Wed, 13 Dec 2000 05:03:17 +0000
Subject: [Linux-ia64] switch_stack position
Message-Id: <marc-linux-ia64-105590678205821@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

IA64 code assumes that struct switch_stack always follows struct
pt_regs on stack.  This is not always true, unw_init_running() pushes
switch_stack from anywhere, so pt_regs and switch_stack can be
separate.

I am adding support for separate pt_regs and switch_stack by adding
	struct switch_stack *sw;
to struct thread and
	struct switch_stack *prev_sw;
to struct switch_stack.  DO_SAVE_SWITCH_STACK and DO_LOAD_SWITCH_STACK
track the position of the last switch_stack (LIFO), copy_thread sets
prev_sw to NULL for a new process.

Besides fixing the incorrect assumption about the relative placement of
pt_regs and switch_stack, this removes the need for kdb for ia64 to
save switch_stack on every fault.  Instead the switch_stack can be
delayed until we know that kdb is actually going to do some work.  It
is a little more work for kdb to unwind from switch_stack back to the
point that pt_regs was pushed but it will be much faster than
DO_SAVE_SWITCH_STACK on every fault.

Before I spend too much time on this change, is there any obvious
reason why separate pt_regs and switch_stack will not work, as long as
I track where switch_stack is?


