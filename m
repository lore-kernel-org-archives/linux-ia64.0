From: Jesse Barnes <jbarnes@sgi.com>
Date: Wed, 19 Jan 2005 22:03:35 +0000
Subject: Re: pgprot_writecombine & shub 1.x
Message-Id: <200501191403.35459.jbarnes@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501111200.02504.jbarnes@sgi.com>
In-Reply-To: <200501111200.02504.jbarnes@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday, January 19, 2005 2:00 pm, Luck, Tony wrote:
> More EFI ignorance on my part ... do you really have to check
> each *byte* of the address range, or is there some larger unit
> that you could step by?  It doesn't seem rational that this
> attribute could change for anything less than cache line size.

I think I could stride by 1 << EFI_PAGE_SHIFT since the memory map is 
described in that granularity.

Jesse
