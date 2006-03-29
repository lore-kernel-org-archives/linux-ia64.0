From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 29 Mar 2006 08:28:18 +0000
Subject: RE: accessed/dirty bit handler tuning
Message-Id: <200603290827.k2T8RXg04578@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44157CF1.5060902@bull.net>
In-Reply-To: <44157CF1.5060902@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zoltan Menyhart wrote on Wednesday, March 29, 2006 12:12 AM
> > The Itanium architects agree with you ... the architecture would allow
> > for an implementation where the itc becomes visible after the ld8 that
> > is checking the pte hasn't changed.
> > 
> > Ken and I messed with your patch a bit (to match the style of the rest
> > of ivt.S, and to drop some pointless differences between the trap 8, 9
> > and 10 handlers).  Here's what I plan to checkin:
> 
> Well, it looks correct.
> 
> We'll have to have a look at the other places like "vhpt_miss",...


Oh my gosh, my worst nightmare becomes the reality, :-( It is unacceptable
to have srlz.d in vhpt_miss.  Couple of alternatives:

(1) strip off all ptc.g related instructions in vhpt and just let the hpw
    walker do the job.  Kernel can take double faults, but after all, with
    what people do to ia64 kernel, this might be the best solution.

(2) add 20 cycles of delay in front of ptc.g

(3) dynamically patch out srlz.d for McK/Madison/Montecito processor.

(4) .....

- Ken
