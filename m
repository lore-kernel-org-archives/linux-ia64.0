From: Michael Raymond <mraymond@sgi.com>
Date: Wed, 02 Mar 2005 22:03:20 +0000
Subject: Re: user-mode interrupt handling
Message-Id: <20050302160317.A79696@goliath.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16924.63777.712927.18129@berry.gelato.unsw.EDU.AU>
In-Reply-To: <16924.63777.712927.18129@berry.gelato.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

    I've done some better quality benchmarking to compare the two approaches
and here are my results.  This was done on an idle 1Ghz system with kernel
preemption.

      Total Cost of Empty Handler    Time to First User Instruction
ULI   2.9us                          1.34us
UMIH  3.4us                          7.98us

    Total Cost was measured as the slow down per interrupt of an application
doing other work and periodically being interrupted.  First Instruction was
measured as the time from the IRQ code to the first user space instruction.

    For my purposes, Mr Amdahl says that the Total Cost difference is
irrelevant.  In the application space that I'm targetting, I can expect code
running at 50+ kHz and needing to respond to every interrupt before the next
one.  For those kind of applications, the latency issue becomes a problem.
    Prof Chubb, our code bases share a good deal of common infrastructure
and I imagine at a user API level we could produce library code that allows
the user to not care about the underlying methods.  ULI users need really
low latency while UMIH appears to target environments that can batch work.
    With the goal of getting something checked in, would it make sense to
merge our code that affects common Linux C code?
      	       	    	    	   	   	Thanks,
						       Michael

On Thu, Feb 24, 2005 at 08:44:01AM +1100, Peter Chubb wrote:
> 
> 
> For your delectation --- here's the stuff to be able to handle
> interrupts from user space, for all architectures that use
> GENERIC_HARDIRQS (which of course includes IA64).
> 
> I'm not expecting this to be included; it's just for comparison with the
> ULI patch that Michael Raymond posted a pointer to.

-- 
Michael A. Raymond              Office: (651) 683-3434
Core OS Group                   Real-Time System Software
