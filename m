From: Matthew Chapman <matthewc@cse.unsw.edu.au>
Date: Wed, 05 Mar 2008 22:36:49 +0000
Subject: Re: Interval timer
Message-Id: <20080305223649.GA25774@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080305094128.GA30069@cse.unsw.EDU.AU>
In-Reply-To: <20080305094128.GA30069@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Mar 05, 2008 at 03:19:16PM -0600, Robin Holt wrote:
> 
> How about setting HZ to 1024 and using regular add_timer() timers?

I'd really like to get shorter timeouts in the common case.

(Also, I was trying to avoid dealing with timer ticks at all in my
hypervisor, leaving the details of setting ITC and ITM in the hands of
the [single trusted] Linux kernel running on the hypervisor.  I guess I
could run a uniformly fast timer tick in the hypervisor and deliver
timer interrupts to the guest kernel on the closest tick, but I don't
really like that solution, it's incurring extra overhead 'just in case'
you happen to need a timeout in the hypervisor.)

Anyway, I've written code to hijack ITM if the existing ITM is too far
in the future, and then restore the previous value of ITM after the
interrupt.  It works okay in the absence of better solutions.

Matt

