From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Mon, 04 Apr 2005 00:22:37 +0000
Subject: Re: [PATCH] ULI 2.6.12
Message-Id: <16976.35021.822207.686714@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050401130602.A123752@goliath.americas.sgi.com>
In-Reply-To: <20050401130602.A123752@goliath.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Michael" = Michael Raymond <mraymond@sgi.com> writes:

Michael>     Here's a patch of the ULI code to Tony's pre-2.6.12 tree.
Michael> Signed-off-by: Michael A Raymond <mraymond@sgi.com>

Michael> All IRQ handlers are called out of
Michael> do_IRQ().  It's not until do_IRQ() is called that ia64_eoi()
Michael> is called to complete the ACK and allow lower priority
Michael> interrupts into the system.  

This is one thing that  bothers me most about this approach.  User
code is invoked before acknowledging the interrupt to the interrupt
controller.  As a general rule, kernel code should not trust user code
for its correct operation.  If the ULI does not clear the interrupt,
(because it is malicious, say) then there is a distinct possibility of
DOS here.


However, I think that the thing that bothers me *most* about SGI's ULI
approach is that a full context switch is not done.  The ULI runs as
if it were in the interrupted process's context.  `current' isn't
changed, so it runs with the privileges of the interrupted process.
The *way* it runs (CPU bound, presumably) will affect the scheduler's
decisions about how to run the interrupted process in the next
timeslice.  For most interrupt handlers this won't matter, but it'd be
relatively easy to construct a malicious one to slow particular
processes.

Running at interrupted process provilege doesn't matter very much,
because all system calls are mapped onto uli_syscall if you're running
as a user-level interrupt.  However, this severely limits what you can
do in a handler.  For example, you can't wake threads waiting on  a
futex (something we find very common in a user-level interrupt handler).


--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
