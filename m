From: "Magenheimer, Dan (HP Labs Fort Collins)" <dan.magenheimer@hp.com>
Date: Fri, 09 Sep 2005 23:19:56 +0000
Subject: RE: [RFC] timer_interrupt: Avoid device timeouts by freezing time if system froze
Message-Id: <516F50407E01324991DD6D07B0531AD569596C@cacexc12.americas.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0509091501240.12956@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0509091501240.12956@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We've found that guests are pretty resilient to
"timeouts", though its quite possible they've never
really exceeded 200 milliseconds.

> -----Original Message-----
> From: Luck, Tony [mailto:tony.luck@intel.com] 
> Sent: Friday, September 09, 2005 4:36 PM
> To: Magenheimer, Dan (HP Labs Fort Collins); Christoph 
> Lameter; linux-ia64@vger.kernel.org
> Subject: RE: [RFC] timer_interrupt: Avoid device timeouts by 
> freezing time if system froze
> 
> >I am aware of at least two ia64 virtualization systems
> >that rely on the existing behavior to compensate for
> >the fact that one guest linux may be inactive while another
> >is active.  This isn't to say that another solution
> >couldn't be found, but just turning off the existing
> >behavior doesn't seem like a good alternative. 
> 
> There must be some minimum frequency at which a hypervisor
> allows a guest to run in order for it to operate normally
> [e.g. a guest that gets no cpu time for several seconds at
> a stretch will experience network time-outs with external
> systems that it is unable to supply with "keep-alive" packets].
> 
> I'm not sure what that minimum frequency is, but I expect that
> it may be contrained by some of the shorter TCP timeouts.  I
> think that there is one around the 200 milli-second mark.
> 
> So possibly a hypervisor that starves a guest for long enough
> to trigger Christoph's patch has other problems than just
> keeping time correct in the guest.
> 
> -Tony
> 
