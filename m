From: Matthew Wilcox <matthew@wil.cx>
Date: Thu, 06 Jan 2005 19:47:33 +0000
Subject: Re: [PATCH] cleanup swiotlb.c a bit
Message-Id: <20050106194733.GM27371@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501060945.12364.jbarnes@engr.sgi.com>
In-Reply-To: <200501060945.12364.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jan 06, 2005 at 11:38:07AM -0800, David Mosberger wrote:
> For example, something like this:
> 
> +	io_tlb_start = alloc_bootmem_low_pages(io_tlb_nslabs *
> +					       (1 << IO_TLB_SHIFT));
> 
> I find more readable if it's formatted as:
> 
> 	io_tlb_start = alloc_bootmem_low_pages(io_tlb_nslabs
> 					       * (1 << IO_TLB_SHIFT));

I find the former more readable.  It lets you know there's something
coming on the next line.

> Well, it probably should move outside of the ia64 tree anyhow.  The
> way x86_64 includes swiotlb.c at the moment is just absolutely gross.

kernel/swiotlb.c would make most sense, I guess?

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
