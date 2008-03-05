From: Matthew Chapman <matthewc@cse.unsw.edu.au>
Date: Wed, 05 Mar 2008 10:22:32 +0000
Subject: Re: Interval timer
Message-Id: <20080305102232.GA24631@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080305094128.GA30069@cse.unsw.EDU.AU>
In-Reply-To: <20080305094128.GA30069@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Mar 05, 2008 at 03:53:52AM -0600, Robin Holt wrote:
> On Wed, Mar 05, 2008 at 08:41:28PM +1100, Matthew Chapman wrote:
> > Is there any interval timer on HP zx1 platforms, other than the
> > CPU-based ITC/ITM?
> 
> How fine grained do you need?  How much jitter are you willing to
> tolerate?  How much multiplexing are we talking about?

I don't need any strong guarantees other than the fact that an
interrupt arrives 'sometime in the next millisecond' after
programming the timer - ideally the timeouts I want are of the
order of 10 microseconds (+/- an order of magnitude), but large
jitter is fine.

I'm just looking for a separate mechanism for short-ish timeouts
in my hypervisor, that doesn't involve having to hijack ITM
(the latter being used for HZ-order events).

Matt

