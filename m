From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 14 Dec 2000 03:46:20 +0000
Subject: Re: [Linux-ia64] switch_stack position
Message-Id: <marc-linux-ia64-105590678205829@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205821@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205821@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 13 Dec 2000 18:56:21 -0800, 
David Mosberger <davidm@hpl.hp.com> wrote:
>>>>>> On Wed, 13 Dec 2000 16:03:17 +1100, Keith Owens <kaos@melbourne.sgi.com> said:
>  Keith> I am adding support for separate pt_regs and switch_stack by
>  Keith> adding struct switch_stack *sw; to struct thread and struct
>  Keith> switch_stack *prev_sw; to struct switch_stack.
>  Keith> DO_SAVE_SWITCH_STACK and DO_LOAD_SWITCH_STACK track the
>  Keith> position of the last switch_stack (LIFO), copy_thread sets
>  Keith> prev_sw to NULL for a new process.
>
>Ouch.

No big deal.  5 new instructions (1 extra bundle) in save_switch_stack,
3 new instructions (no extra bundles) in load_switch_stack.  One
assignment to 0 in copy_thread().  Plus one __u64 in struct
switch_stack.

>  Keith> this removes the need for kdb for ia64 to save switch_stack
>  Keith> on every fault.  Instead the switch_stack can be delayed
>  Keith> until we know that kdb is actually going to do some work.  It
>  Keith> is a little more work for kdb to unwind from switch_stack
>  Keith> back to the point that pt_regs was pushed but it will be much
>  Keith> faster than DO_SAVE_SWITCH_STACK on every fault.
>
>That may be a legitimate goal, but surely it doesn't warrant rewriting
>the context switch code.  In fact, if you're willing to unwind, all
>the code you need is there already.

The problem is anything that wants to look at other processes on SMP;
kdb and get_wchan are two examples.  Currently kdb assumes that any
process which is not current on _this_ cpu is blocked.  But the process
could be running on another cpu.  kdb needs a safe way of getting the
last switch_stack for any process or of determining that the process
has no switch_stack and therefore cannot be reported.

>  Keith> Before I spend too much time on this change, is there any
>  Keith> obvious reason why separate pt_regs and switch_stack will not
>  Keith> work, as long as I track where switch_stack is?
>
>Like I said above, they already are separate.  The only places where
>they are assumed to be consecutive is where (a) the switch stack is
>needed anyhow (clone(), for example) or where unwinding would be too
>costly (unaligned handler).

My earlier mail was a bit strong, I had missed unw_init_running(),
there are no comments on that function to say what it is doing.
Nevertheless I have a need to safely find the switch_stack data on
arbitrary processes.  Tracking the position of the latest switch_stack
via a LIFO chain is cheap for the benefits it gives.


