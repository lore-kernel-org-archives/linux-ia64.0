From: Keith Owens <kaos@sgi.com>
Date: Wed, 19 Jan 2005 22:25:35 +0000
Subject: Re: [patch] Resched skip_rbs_switch to run 4 cycles faster on McKinley-type cores.
Message-Id: <17598.1106173535@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501190500.j0J505jY002441@napali.hpl.hp.com>
In-Reply-To: <200501190500.j0J505jY002441@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Damn, I was in the middle of developing a patch against this area :(.

David, since you are redoing some of this code, I probably need to
discuss my changes.  My aim is to allow the kernel unwinder to work on
the per-cpu MCA and INIT stacks that Russ Anderson (rja) recently
added.  This has never been an issue before because we only had one
stack and could not handle INIT over MCA.

The problem with unwinding from the MCA or INIT stacks is handling the
change of rbs.  The current code assumes that all kernel work is done
on the same rbs, which is not true for the MCA and INIT stacks.  I plan
to change the meaning of pt_regs ar_bspstore and ar_rnat.  Instead of
being garbage when the interrupted code was in the kernel, ar_bspstore
and ar_rnat are set to zero.  The test for "do I skip_rbs_switch"
changes from pUStk to "is saved ar_bspstore non-zero".

Interrupts in kernel context save a zero ar_bspstore and skip the rbs
swicth on return from interrupt.  Interrupts in user context save a
valid ar_bspstore and switch rbs on exit.  MCA and INIT events will
synthesize and save struct pt_regs on the MCA/INIT stack, this pt_regs
will contain non-zero ar_bspstore pointing back to the previous bsp,
which could be in a kernel or user space stack.

Comments?

