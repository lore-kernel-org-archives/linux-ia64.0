From: Brian Gerst <bgerst@didntduck.org>
Date: Thu, 14 Oct 2004 17:30:21 +0000
Subject: Re: [PATCH] General purpose zeroed page slab
Message-Id: <416EB7AD.4040302@didntduck.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1oej5s0po.fsf@wilson.mkp.net>
In-Reply-To: <yq1oej5s0po.fsf@wilson.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Martin K. Petersen" <mkp@wildopensource.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, akpm@osdl.org, tony.luck@intel.com

Martin K. Petersen wrote:
> A while back Bill Irwin converted the page table code on ppc64 to use
> a zeroed page slab.  I recently did the same on ia64 and got a
> significant performance improvement in terms of fault time (4 usec ->
> 700 nsec).
> 
> This cache needs to be initialized fairly early on and so far we've
> called it from pgtable_cache_init() on both archs.  However, Tony Luck
> thought it might be useful to have a general purpose slab cache with
> zeroed pages.  And other architectures might decide to use it for
> their page tables too.
> 
> Consequently here's a patch that puts this functionality in slab.c.
> 
> Signed-off-by: Martin K. Petersen <mkp@wildopensource.com>
> 

This doesn't work as you expect it does.  The constructor is only called 
when a new slab is created, for each new object on the slab.  It is 
_not_ run again when an object is freed.  So if a page is freed then 
immediately reallocated it will contain garbage.

--
				Brian Gerst
