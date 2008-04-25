From: Matthew Wilcox <matthew@wil.cx>
Date: Fri, 25 Apr 2008 18:50:00 +0000
Subject: Re: [PATCH] allocate multiple contiguous pages via uncached allocator -v2
Message-Id: <20080425185000.GK14990@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080425184606.GA13773@sgi.com>
In-Reply-To: <20080425184606.GA13773@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dean Nelson <dcn@sgi.com>
Cc: jes@sgi.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Apr 25, 2008 at 01:46:06PM -0500, Dean Nelson wrote:
> +++ linux-2.6/include/asm-ia64/uncached.h	2008-04-25 13:25:06.821572061 -0500
> @@ -8,5 +8,5 @@
>   * Prototypes for the uncached page allocator
>   */
>  
> -extern unsigned long uncached_alloc_page(int nid);
> -extern void uncached_free_page(unsigned long);
> +extern unsigned long uncached_alloc_page(int, int);
> +extern void uncached_free_page(unsigned long, int);

It would be good to name the arguments, particularly since you can't
identify them by type.

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
