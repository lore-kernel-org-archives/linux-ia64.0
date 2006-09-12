From: Andi Kleen <ak@suse.de>
Date: Tue, 12 Sep 2006 11:11:23 +0000
Subject: Re: [PATCH 5/6] Optional ZONE_DMA for x86_64
Message-Id: <200609121311.23879.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060911222755.4849.17749.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060911222755.4849.17749.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 12 September 2006 13:40, Matthew Wilcox wrote:
> On Tue, Sep 12, 2006 at 08:40:22AM +0200, Andi Kleen wrote:
> > I think I would prefer to not make GFP_DMA32 optional.
> > Adding a 4GB limit CONFIG to a 64bit kernel just seems somewhat
> > dumb.
>
> Hmm?  I would think that the majority of x86-64 users have <4GB.

Yes still it feels dumb, especially for something which you're unlikely
to benchmark a difference of.

> I bought an ASUS P5RD1-VM motherboard a few months ago which
> has 2 DIMM slots.  Look at their list of 'hot' motherboards:
> http://usa.asus.com/products2.aspx?l1=3&l2 I don't see a single one
> with more than 4 slots.  2GB DIMMs are hovering around the $400 mark;
> I'm not convinced that your average user is spending $1200 on RAM at
> this point.

4GB of RAM already gives you memory above the 32bit mark because
the PCI hole needs some below 4GB. The RAM below it is moved up.
So you need >4GB support even on the lowend boards when you
plug in 2x 2GB.

-Andi
