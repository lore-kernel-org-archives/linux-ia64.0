From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 14 Dec 2000 02:56:21 +0000
Subject: Re: [Linux-ia64] switch_stack position
Message-Id: <marc-linux-ia64-105590678205828@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205821@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205821@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 13 Dec 2000 16:03:17 +1100, Keith Owens <kaos@melbourne.sgi.com> said:

  Keith> IA64 code assumes that struct switch_stack always follows
  Keith> struct pt_regs on stack.

Certainly not.  There are a _few_ places where this is assumed, but
it's certainly not true in general and IA-64 Linux certainly doesn't
make that assumption in all but a few very specific places.

  Keith> This is not always true, unw_init_running() pushes
  Keith> switch_stack from anywhere, so pt_regs and switch_stack can
  Keith> be separate.

Not to mention blocked threads...

  Keith> I am adding support for separate pt_regs and switch_stack by
  Keith> adding struct switch_stack *sw; to struct thread and struct
  Keith> switch_stack *prev_sw; to struct switch_stack.
  Keith> DO_SAVE_SWITCH_STACK and DO_LOAD_SWITCH_STACK track the
  Keith> position of the last switch_stack (LIFO), copy_thread sets
  Keith> prev_sw to NULL for a new process.

Ouch.

  Keith> Besides fixing the incorrect assumption about the relative
  Keith> placement of pt_regs and switch_stack,

You haven't shown a case where this assumption is made incorrectly.

  Keith> this removes the need for kdb for ia64 to save switch_stack
  Keith> on every fault.  Instead the switch_stack can be delayed
  Keith> until we know that kdb is actually going to do some work.  It
  Keith> is a little more work for kdb to unwind from switch_stack
  Keith> back to the point that pt_regs was pushed but it will be much
  Keith> faster than DO_SAVE_SWITCH_STACK on every fault.

That may be a legitimate goal, but surely it doesn't warrant rewriting
the context switch code.  In fact, if you're willing to unwind, all
the code you need is there already.

  Keith> Before I spend too much time on this change, is there any
  Keith> obvious reason why separate pt_regs and switch_stack will not
  Keith> work, as long as I track where switch_stack is?

Like I said above, they already are separate.  The only places where
they are assumed to be consecutive is where (a) the switch stack is
needed anyhow (clone(), for example) or where unwinding would be too
costly (unaligned handler).

	--david

