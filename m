From: Daniel Vetter <daniel@ffwll.ch>
Date: Wed, 16 Nov 2022 10:48:56 +0000
Subject: Re: [PATCH mm-unstable v1 13/20] media: videobuf-dma-sg: remove FOLL_FORCE usage
Message-Id: <Y3TAGAUIo/IR+tAa@phenom.ffwll.local>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221116102659.70287-1-david@redhat.com>
 <20221116102659.70287-14-david@redhat.com>
In-Reply-To: <20221116102659.70287-14-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, Nadav Amit <namit@vmware.com>, linux-kselftest@vger.kernel.org, sparclinux@vger.kernel.org, Shuah Khan <shuah@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-samsung-soc@vger.kernel.org, linux-rdma@vger.kernel.org, x86@kernel.org, Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@infradead.org>, Jason Gunthorpe <jgg@ziepe.ca>, Vlastimil Babka <vbabka@suse.cz>, linux-media@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, John Hubbard <jhubbard@nvidia.com>, linux-um@lists.infradead.org, etnaviv@lists.freedesktop.org, Alex Williamson <alex.williamson@redhat.com>, Peter Xu <peterx@redhat.com>, Muchun Song <songmuchun@bytedance.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, Oded Gabbay <ogabbay@kernel.org>, linux-mips@vger.kernel.org, linux-perf-users@vger.kernel.org, linux-security-module@vger.kernel.org, linux-alpha@vger.kernel.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

On Wed, Nov 16, 2022 at 11:26:52AM +0100, David Hildenbrand wrote:
> GUP now supports reliable R/O long-term pinning in COW mappings, such
> that we break COW early. MAP_SHARED VMAs only use the shared zeropage so
> far in one corner case (DAXFS file with holes), which can be ignored
> because GUP does not support long-term pinning in fsdax (see
> check_vma_flags()).
> 
> Consequently, FOLL_FORCE | FOLL_WRITE | FOLL_LONGTERM is no longer required
> for reliable R/O long-term pinning: FOLL_LONGTERM is sufficient. So stop
> using FOLL_FORCE, which is really only for ptrace access.
> 
> Cc: Mauro Carvalho Chehab <mchehab@kernel.org>
> Signed-off-by: David Hildenbrand <david@redhat.com>

I looked at this a while ago when going through some of the follow_pfn
stuff, so

Reviewed-by: Daniel Vetter <daniel.vetter@ffwll.ch>

> ---
>  drivers/media/v4l2-core/videobuf-dma-sg.c | 14 +++++---------
>  1 file changed, 5 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/media/v4l2-core/videobuf-dma-sg.c b/drivers/media/v4l2-core/videobuf-dma-sg.c
> index f75e5eedeee0..234e9f647c96 100644
> --- a/drivers/media/v4l2-core/videobuf-dma-sg.c
> +++ b/drivers/media/v4l2-core/videobuf-dma-sg.c
> @@ -151,17 +151,16 @@ static void videobuf_dma_init(struct videobuf_dmabuf *dma)
>  static int videobuf_dma_init_user_locked(struct videobuf_dmabuf *dma,
>  			int direction, unsigned long data, unsigned long size)
>  {
> +	unsigned int gup_flags = FOLL_LONGTERM;
>  	unsigned long first, last;
> -	int err, rw = 0;
> -	unsigned int flags = FOLL_FORCE;
> +	int err;
>  
>  	dma->direction = direction;
>  	switch (dma->direction) {
>  	case DMA_FROM_DEVICE:
> -		rw = READ;
> +		gup_flags |= FOLL_WRITE;
>  		break;
>  	case DMA_TO_DEVICE:
> -		rw = WRITE;
>  		break;
>  	default:
>  		BUG();
> @@ -177,14 +176,11 @@ static int videobuf_dma_init_user_locked(struct videobuf_dmabuf *dma,
>  	if (NULL = dma->pages)
>  		return -ENOMEM;
>  
> -	if (rw = READ)
> -		flags |= FOLL_WRITE;
> -
>  	dprintk(1, "init user [0x%lx+0x%lx => %lu pages]\n",
>  		data, size, dma->nr_pages);
>  
> -	err = pin_user_pages(data & PAGE_MASK, dma->nr_pages,
> -			     flags | FOLL_LONGTERM, dma->pages, NULL);
> +	err = pin_user_pages(data & PAGE_MASK, dma->nr_pages, gup_flags,
> +			     dma->pages, NULL);
>  
>  	if (err != dma->nr_pages) {
>  		dma->nr_pages = (err >= 0) ? err : 0;
> -- 
> 2.38.1
> 

-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch
