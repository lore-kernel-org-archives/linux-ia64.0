From: Michael Raymond <mraymond@sgi.com>
Date: Mon, 04 Apr 2005 13:31:44 +0000
Subject: Re: [PATCH] ULI 2.6.12
Message-Id: <20050404083141.B127642@goliath.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050401130602.A123752@goliath.americas.sgi.com>
In-Reply-To: <20050401130602.A123752@goliath.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

    These are all valid concerns.

On Mon, Apr 04, 2005 at 10:22:37AM +1000, Peter Chubb wrote:
> This is one thing that  bothers me most about this approach.  User
> code is invoked before acknowledging the interrupt to the interrupt
> controller.  As a general rule, kernel code should not trust user code
> for its correct operation.  If the ULI does not clear the interrupt,
> (because it is malicious, say) then there is a distinct possibility of
> DOS here.
 
    The idea is that only trusted code by priviledged users will be run.
Let's assume for a moment that this isn't true.  My understanding of the
IA64 code is the following.

- Interrupt handling ends up in __do_IRQ()
- __do_IRQ() ACKs the interrupt with an infrastructure provided function
- control passes to handle_IRQ_event()
- Each registered handler is run.  These include traditional kernel drivers,
  ULIs, etc
- control returns through __do_IRQ() to ia64_handle_irq()
- ia64_eoi() is called to lower the blocked interrupt class and allow the
  interrupt to be handled again
 
> However, I think that the thing that bothers me *most* about SGI's ULI
> approach is that a full context switch is not done.  The ULI runs as
> if it were in the interrupted process's context.  `current' isn't
> changed, so it runs with the privileges of the interrupted process.
> The *way* it runs (CPU bound, presumably) will affect the scheduler's
> decisions about how to run the interrupted process in the next
> timeslice.  For most interrupt handlers this won't matter, but it'd be
> relatively easy to construct a malicious one to slow particular
> processes.

    Again the idea is that the handler function was registered by root or
some priviledged developer making a conscious decision.  This is currently
protected by permissions on the /dev/uli file.  If you'd like me to add
permission checks to the kernel functions I'd be happy to do it.
    Another help here is that handlers can only run for a certain amount of
time.  I think the arbitrarily chosen limit right now is ~10us.  A handler
that has to do anything more than simple work should wake up a thread /
process to do so.  I can make that time limit configurable if you'd like.
 
> Running at interrupted process provilege doesn't matter very much,
> because all system calls are mapped onto uli_syscall if you're running
> as a user-level interrupt.  However, this severely limits what you can
> do in a handler.  For example, you can't wake threads waiting on  a
> futex (something we find very common in a user-level interrupt handler).

    Currently its own semaphore approach is supported.  If you'd like me to
switch it to use futexes I can do that.
       	     	 	       	       		Thanks,
       	     	 	       	       			Michael
-- 
Michael A. Raymond              Office: (651) 683-3434
Core OS Group                   Real-Time System Software
