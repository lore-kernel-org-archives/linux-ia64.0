From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 16 May 2008 23:15:52 +0000
Subject: Re: [PATCH 3/3] ia64: Call migration code on correctable errors v5
Message-Id: <Pine.LNX.4.64.0805161614020.5114@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080516192359.GF7885@sgi.com>
In-Reply-To: <20080516192359.GF7885@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russ Anderson <rja@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>

On Fri, 16 May 2008, Russ Anderson wrote:

> Index: linus/include/asm-ia64/page.h
> =================================> --- linus.orig/include/asm-ia64/page.h	2008-05-14 15:36:06.826294509 -0500
> +++ linus/include/asm-ia64/page.h	2008-05-15 12:59:06.022712144 -0500
> @@ -122,6 +122,7 @@ extern unsigned long max_low_pfn;
>  #endif
>  
>  #define page_to_phys(page)	(page_to_pfn(page) << PAGE_SHIFT)
> +#define	phys_to_page(kaddr)	(pfn_to_page(kaddr >> PAGE_SHIFT))
>  #define virt_to_page(kaddr)	pfn_to_page(__pa(kaddr) >> PAGE_SHIFT)
>  #define pfn_to_kaddr(pfn)	__va((pfn) << PAGE_SHIFT)

There is still a whitespace inconsistency here. Sorry about the 
earlier cryptic ocmment. Replacing the tab in phys_to_page 
with a blank should fix things.

