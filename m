From: Daniel Vetter <daniel@ffwll.ch>
Date: Wed, 16 Nov 2022 10:49:43 +0000
Subject: Re: [PATCH mm-unstable v1 14/20] drm/etnaviv: remove FOLL_FORCE usage
Message-Id: <Y3TAR7Ndmat+zYpJ@phenom.ffwll.local>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221116102659.70287-1-david@redhat.com>
 <20221116102659.70287-15-david@redhat.com>
In-Reply-To: <20221116102659.70287-15-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, etnaviv@lists.freedesktop.org, dri-devel@lists.freedesktop.org, linux-samsung-soc@vger.kernel.org, linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-perf-users@vger.kernel.org, linux-security-module@vger.kernel.org, linux-kselftest@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jason Gunthorpe <jgg@ziepe.ca>, John Hubbard <jhubbard@nvidia.com>, Peter Xu <peterx@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Nadav Amit <namit@vmware.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>, Muchun Song <songmuchun@bytedance.com>, Shuah Khan <shuah@kernel.org>, Lucas Stach <l.stach@pengutronix.de>, David Airlie <airlied@gmail.com>, Oded Gabbay <ogabbay@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Christoph Hellwig <hch@infradead.org>, Alex Williamson <alex.williamson@redhat.com>, Daniel Vetter <daniel.vetter@ffwll.ch>, Russell King <linux+etnaviv@armlinux.org.uk>, Christian Gmeiner <christian.gmeiner@gmail.com>

On Wed, Nov 16, 2022 at 11:26:53AM +0100, David Hildenbrand wrote:
> GUP now supports reliable R/O long-term pinning in COW mappings, such
> that we break COW early. MAP_SHARED VMAs only use the shared zeropage so
> far in one corner case (DAXFS file with holes), which can be ignored
> because GUP does not support long-term pinning in fsdax (see
> check_vma_flags()).
> 
> commit cd5297b0855f ("drm/etnaviv: Use FOLL_FORCE for userptr")
> documents that FOLL_FORCE | FOLL_WRITE was really only used for reliable
> R/O pinning.
> 
> Consequently, FOLL_FORCE | FOLL_WRITE | FOLL_LONGTERM is no longer required
> for reliable R/O long-term pinning: FOLL_LONGTERM is sufficient. So stop
> using FOLL_FORCE, which is really only for ptrace access.
> 
> Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
> Cc: Lucas Stach <l.stach@pengutronix.de>
> Cc: Russell King <linux+etnaviv@armlinux.org.uk>
> Cc: Christian Gmeiner <christian.gmeiner@gmail.com>
> Cc: David Airlie <airlied@gmail.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Reviewed-by: Daniel Vetter <daniel.vetter@ffwll.ch>

Also ack for merging through whatever tree suits best, since I guess this
should all land together.
-Daniel

> ---
>  drivers/gpu/drm/etnaviv/etnaviv_gem.c | 8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/gpu/drm/etnaviv/etnaviv_gem.c b/drivers/gpu/drm/etnaviv/etnaviv_gem.c
> index cc386f8a7116..efe2240945d0 100644
> --- a/drivers/gpu/drm/etnaviv/etnaviv_gem.c
> +++ b/drivers/gpu/drm/etnaviv/etnaviv_gem.c
> @@ -638,6 +638,7 @@ static int etnaviv_gem_userptr_get_pages(struct etnaviv_gem_object *etnaviv_obj)
>  	struct page **pvec = NULL;
>  	struct etnaviv_gem_userptr *userptr = &etnaviv_obj->userptr;
>  	int ret, pinned = 0, npages = etnaviv_obj->base.size >> PAGE_SHIFT;
> +	unsigned int gup_flags = FOLL_LONGTERM;
>  
>  	might_lock_read(&current->mm->mmap_lock);
>  
> @@ -648,14 +649,15 @@ static int etnaviv_gem_userptr_get_pages(struct etnaviv_gem_object *etnaviv_obj)
>  	if (!pvec)
>  		return -ENOMEM;
>  
> +	if (!userptr->ro)
> +		gup_flags |= FOLL_WRITE;
> +
>  	do {
>  		unsigned num_pages = npages - pinned;
>  		uint64_t ptr = userptr->ptr + pinned * PAGE_SIZE;
>  		struct page **pages = pvec + pinned;
>  
> -		ret = pin_user_pages_fast(ptr, num_pages,
> -					  FOLL_WRITE | FOLL_FORCE | FOLL_LONGTERM,
> -					  pages);
> +		ret = pin_user_pages_fast(ptr, num_pages, gup_flags, pages);
>  		if (ret < 0) {
>  			unpin_user_pages(pvec, pinned);
>  			kvfree(pvec);
> -- 
> 2.38.1
> 

-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch
