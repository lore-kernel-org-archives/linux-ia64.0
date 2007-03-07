From: Horms <horms@verge.net.au>
Date: Wed, 07 Mar 2007 01:03:21 +0000
Subject: Re: [patch 1/3] IA64: put kdump_find_rsvd_region in __init
Message-Id: <20070307010319.GH17090@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070306073755.795769464@tabatha.lab.ultramonkey.org>
In-Reply-To: <20070306073755.795769464@tabatha.lab.ultramonkey.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 06, 2007 at 04:34:44PM +0800, Zou, Nanhai wrote:
> > -----Original Message-----
> > From: Horms [mailto:horms@verge.net.au]
> > Sent: 2007年3月6日 15:29
> > To: Linux-IA64; fastboot@lists.osdl.org
> > Cc: Luck, Tony; Zou, Nanhai; Magnus Damm
> > Subject: [patch 1/3] IA64: put kdump_find_rsvd_region in __init
> > 
> > kdump_find_rsvd_region() is only called by
> > reserve_memory() which is in __init, so it seems that
> > kdump_find_rsvd_region() should also be in there.
> > 
> > Signed-off-by: Simon Horman <horms@verge.net.au>
> > 
> > Index: linux-2.6/arch/ia64/kernel/efi.c
> > =================================> > --- linux-2.6.orig/arch/ia64/kernel/efi.c	2007-03-06 16:30:10.000000000
> > +0900
> > +++ linux-2.6/arch/ia64/kernel/efi.c	2007-03-06 16:30:13.000000000 +0900
> > @@ -1136,7 +1136,7 @@
> >  /* find a block of memory aligned to 64M exclude reserved regions
> >     rsvd_regions are sorted
> >   */
> > -unsigned long
> > +unsigned long __init
> >  kdump_find_rsvd_region (unsigned long size,
> >  		struct rsvd_region *r, int n)
> >  {
> > 
> > --
> > 
>  This patch looks good to me.

Thanks, it it ok if I repost the patch with Acked-by: you ?

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

