From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Mon, 31 Jan 2005 22:33:03 +0000
Subject: Re: [PATCH 2.6.11] Altix patch for device driver support for the CX port of SGI's TIO chip
Message-Id: <200501311433.03959.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0501311506590.30646-100000@fsgi025.americas.sgi.com>
In-Reply-To: <Pine.LNX.4.44.0501311506590.30646-100000@fsgi025.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday, January 31, 2005 2:27 pm, Luck, Tony wrote:
> >> + sn_irq_info = kmalloc(sn_irq_size, GFP_KERNEL);
> >> + if (sn_irq_info = NULL)
> >> +  return NULL;
> >> +
> >> + memset(sn_irq_info, 0x0, sn_irq_size);
> >
> >You can use kmalloc(sn_irq_size, GFP_KERNEL | __GFP_ZERO); to
> >avoid having to
> >memset it to 0.
>
> Umm, no.  kmalloc() doesn't handle __GFP_ZERO.  There is a
> kcalloc() that returns zeroed memory from the slab.

I was just checking on that to make sure, thanks.  kcalloc it is then.

Jesse
