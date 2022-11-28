From: Hans Verkuil <hverkuil@xs4all.nl>
Date: Mon, 28 Nov 2022 08:17:00 +0000
Subject: Re: [PATCH mm-unstable v1 16/20] mm/frame-vector: remove FOLL_FORCE usage
Message-Id: <08b65ac6-6786-1080-18f8-d2be109c85fc@xs4all.nl>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221116102659.70287-1-david@redhat.com>
 <20221116102659.70287-17-david@redhat.com>
 <81fb0fa3-2e06-b765-56ac-a7d981194e59@redhat.com>
In-Reply-To: <81fb0fa3-2e06-b765-56ac-a7d981194e59@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: David Hildenbrand <david@redhat.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: x86@kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, etnaviv@lists.freedesktop.org, dri-devel@lists.freedesktop.org, linux-samsung-soc@vger.kernel.org, linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-perf-users@vger.kernel.org, linux-security-module@vger.kernel.org, linux-kselftest@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Jason Gunthorpe <jgg@ziepe.ca>, John Hubbard <jhubbard@nvidia.com>, Peter Xu <peterx@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Nadav Amit <namit@vmware.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>, Muchun Song <songmuchun@bytedance.com>, Shuah Khan <shuah@kernel.org>, Lucas Stach <l.stach@pengutronix.de>, David Airlie <airlied@gmail.com>, Oded Gabbay <ogabbay@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Christoph Hellwig <hch@infradead.org>, Alex Williamson <alex.williamson@redhat.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Tomasz Figa <tfiga@chromium.org>, Mauro Carvalho Chehab <mchehab@kernel.org>

Hi David,

On 27/11/2022 11:35, David Hildenbrand wrote:
> On 16.11.22 11:26, David Hildenbrand wrote:
>> FOLL_FORCE is really only for ptrace access. According to commit
>> 707947247e95 ("media: videobuf2-vmalloc: get_userptr: buffers are always
>> writable"), get_vaddr_frames() currently pins all pages writable as a
>> workaround for issues with read-only buffers.
>>
>> FOLL_FORCE, however, seems to be a legacy leftover as it predates
>> commit 707947247e95 ("media: videobuf2-vmalloc: get_userptr: buffers are
>> always writable"). Let's just remove it.
>>
>> Once the read-only buffer issue has been resolved, FOLL_WRITE could
>> again be set depending on the DMA direction.
>>
>> Cc: Hans Verkuil <hverkuil@xs4all.nl>
>> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
>> Cc: Tomasz Figa <tfiga@chromium.org>
>> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
>> Cc: Mauro Carvalho Chehab <mchehab@kernel.org>
>> Signed-off-by: David Hildenbrand <david@redhat.com>
>> ---
>>   drivers/media/common/videobuf2/frame_vector.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/media/common/videobuf2/frame_vector.c b/drivers/media/common/videobuf2/frame_vector.c
>> index 542dde9d2609..062e98148c53 100644
>> --- a/drivers/media/common/videobuf2/frame_vector.c
>> +++ b/drivers/media/common/videobuf2/frame_vector.c
>> @@ -50,7 +50,7 @@ int get_vaddr_frames(unsigned long start, unsigned int nr_frames,
>>       start = untagged_addr(start);
>>         ret = pin_user_pages_fast(start, nr_frames,
>> -                  FOLL_FORCE | FOLL_WRITE | FOLL_LONGTERM,
>> +                  FOLL_WRITE | FOLL_LONGTERM,
>>                     (struct page **)(vec->ptrs));
>>       if (ret > 0) {
>>           vec->got_ref = true;
> 
> 
> Hi Andrew,
> 
> see the discussion at [1] regarding a conflict and how to proceed with
> upstreaming. The conflict would be easy to resolve, however, also
> the patch description doesn't make sense anymore with [1].

Might it be easier and less confusing if you post a v2 of this series
with my patch first? That way it is clear that 1) my patch has to come
first, and 2) that it is part of a single series and should be merged
by the mm subsystem.

Less chances of things going wrong that way.

Just mention in the v2 cover letter that the first patch was added to
make it easy to backport that fix without being hampered by merge
conflicts if it was added after your frame_vector.c patch.

Regards,

	Hans

> 
> 
> On top of mm-unstable, reverting this patch and applying [1] gives me
> an updated patch:
> 
> 
> From 1e66c25f1467c1f1e5f275312f2c6df29308d4df Mon Sep 17 00:00:00 2001
> From: David Hildenbrand <david@redhat.com>
> Date: Wed, 16 Nov 2022 11:26:55 +0100
> Subject: [PATCH] mm/frame-vector: remove FOLL_FORCE usage
> 
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
> Reviewed-by: Daniel Vetter <daniel.vetter@ffwll.ch>
> Acked-by: Hans Verkuil <hverkuil-cisco@xs4all.nl>
> Cc: Hans Verkuil <hverkuil@xs4all.nl>
> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Cc: Tomasz Figa <tfiga@chromium.org>
> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Cc: Mauro Carvalho Chehab <mchehab@kernel.org>
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  drivers/media/common/videobuf2/frame_vector.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/media/common/videobuf2/frame_vector.c b/drivers/media/common/videobuf2/frame_vector.c
> index aad72640f055..8606fdacf5b8 100644
> --- a/drivers/media/common/videobuf2/frame_vector.c
> +++ b/drivers/media/common/videobuf2/frame_vector.c
> @@ -41,7 +41,7 @@ int get_vaddr_frames(unsigned long start, unsigned int nr_frames, bool write,
>      int ret_pin_user_pages_fast = 0;
>      int ret = 0;
>      int err;
> -    unsigned int gup_flags = FOLL_FORCE | FOLL_LONGTERM;
> +    unsigned int gup_flags = FOLL_LONGTERM;
>  
>      if (nr_frames = 0)
>          return 0;
