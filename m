From: Horms <horms@verge.net.au>
Date: Wed, 07 Mar 2007 09:49:33 +0000
Subject: Re: [patch 3/3] IA64: verify the base address of crashkernel
Message-Id: <20070307094928.GB21399@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070306073756.245032985@tabatha.lab.ultramonkey.org>
In-Reply-To: <20070306073756.245032985@tabatha.lab.ultramonkey.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Mar 07, 2007 at 05:06:39PM +0800, Zou, Nanhai wrote:
> > -----Original Message-----
> > From: Horms [mailto:horms@verge.net.au]
> > Sent: 2007年3月7日 15:55
> > To: Zou, Nanhai
> > Cc: Linux-IA64; fastboot@lists.osdl.org; Luck, Tony; Magnus Damm
> > Subject: Re: [patch 3/3] IA64: verify the base address of crashkernel
> > 
> > On Wed, Mar 07, 2007 at 12:50:12PM +0800, Zou, Nanhai wrote:
> > > On Wed, Mar 07, 2007 at 11:46, Horms wrote:
> > > >
> > > > I think that the manual option is also important because it
> > > > maintains feature-compatibility with other architectures. I don't
> > > > consider it a hack that might work purely for the purposes of
> > > > debugging.
> > >
> > > I don't understand why we need to maintain compatibility with other
> > > architectures here. Manfully choose may confuse user, XXX@16M may work
> > > on one arch,but not on another arch. Other architectures need manually
> > > choose crash kernel region simply because they do not support kernel
> > > automatically choose feature.
> > >
> > > I keep the XXX@YYY format to just make kdump script compatible, do
> > > that distributions does not need to maintain different kdump scripts
> > > for different arches.
> > 
> 
> > From my point of view, what you say in the paragraph immediately above
> > Thanks, is this logic better?
> > 
>   Don't write code to improve a "no user will use" feature. 
>   Let's keep kernel code clean.

I think we could argue about this forever :-)

> > kdump_region_verify_rsvd_region (unsigned long base, unsigned long size,
> >                                 struct rsvd_region *rsvd_regions, int n)
> > {
> > 	int i;
> > 
> > 	for (i = 0; i < n; i++) {
> > 		/* Assume that start < end && size > 0 */
> > 		if (__pa(rsvd_regions[i].start) >= base + size &&
> > 		    __pa(rsvd_regions[i].end) < base)
> > 			continue;
>     This is much worse. Have you ever tested it?

Sorry, I wrote it down wrong :(
That should have been:

	if (__pa(rsvd_regions[i].start) >= base + size ||
	    __pa(rsvd_regions[i].end) <= base)
		continue;

I'll do some testing tomorrow. But this was what I was thinking about:

s=__pa(rsvd_regions[i].start)
e=__pa(rsvd_regions[i].end)

                  base             base+size
OK:    s:bad  e:ok |                  |
BAD:   s:bad       |            e:bad |
BAD:   s:bad       |                  |         e:bad
BAD:   s:bad       |            e:bad |
BAD:               |  s:bad     e:bad | 
BAD:               |  s:bad           |         e:bad
OK:                |                  |  s:ok   e:bad

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

