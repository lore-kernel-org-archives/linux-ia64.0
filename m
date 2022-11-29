From: David Hildenbrand <david@redhat.com>
Date: Tue, 29 Nov 2022 09:15:20 +0000
Subject: Re: [PATCH mm-unstable v1 16/20] mm/frame-vector: remove FOLL_FORCE usage
Message-Id: <abcba252-13a0-50aa-79ec-28b649c892cd@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221116102659.70287-1-david@redhat.com>
 <20221116102659.70287-17-david@redhat.com>
 <81fb0fa3-2e06-b765-56ac-a7d981194e59@redhat.com>
 <08b65ac6-6786-1080-18f8-d2be109c85fc@xs4all.nl>
 <9d0bf98a-3d6a-1082-e992-1338e1525935@redhat.com>
 <20221128145927.df895bf1966cfa125cae9668@linux-foundation.org>
 <22b1107b-0acc-5772-a883-8f3c4682eb1b@redhat.com>
 <c2681582-1e24-7ed9-e4fb-e2dd17a93aed@xs4all.nl>
In-Reply-To: <c2681582-1e24-7ed9-e4fb-e2dd17a93aed@xs4all.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Hans Verkuil <hverkuil@xs4all.nl>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-ia64@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nadav Amit <namit@vmware.com>, linux-kselftest@vger.kernel.org, sparclinux@vger.kernel.org, Shuah Khan <shuah@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-samsung-soc@vger.kernel.org, linux-rdma@vger.kernel.org, x86@kernel.org, Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@infradead.org>, Jason Gunthorpe <jgg@ziepe.ca>, Vlastimil Babka <vbabka@suse.cz>, linux-media@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, John Hubbard <jhubbard@nvidia.com>, linux-um@lists.infradead.org, etnaviv@lists.freedesktop.org, Alex Williamson <alex.williamson@redhat.com>, Peter Xu <peterx@redhat.com>, Muchun Song <songmuchun@bytedance.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, Oded Gabbay <ogabbay@kernel.org>, linux-mips@vger.kernel.org, Tomasz Figa <tfiga@chromium.org>, linux-perf-users@vger.kernel.org, linux-security-module@vger.kernel.org, linux-alpha@vger.kernel.org, linux-fsdevel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

On 29.11.22 10:08, Hans Verkuil wrote:
> On 29/11/2022 09:48, David Hildenbrand wrote:
>> On 28.11.22 23:59, Andrew Morton wrote:
>>> On Mon, 28 Nov 2022 09:18:47 +0100 David Hildenbrand <david@redhat.com> wrote:
>>>
>>>>> Less chances of things going wrong that way.
>>>>>
>>>>> Just mention in the v2 cover letter that the first patch was added to
>>>>> make it easy to backport that fix without being hampered by merge
>>>>> conflicts if it was added after your frame_vector.c patch.
>>>>
>>>> Yes, that's the way I would naturally do, it, however, Andrew prefers
>>>> delta updates for minor changes.
>>>>
>>>> @Andrew, whatever you prefer!
>>>
>>> I'm inclined to let things sit as they are.  Cross-tree conflicts
>>> happen, and Linus handles them.  I'll flag this (very simple) conflict
>>> in the pull request, if MM merges second.  If v4l merges second then
>>> hopefully they will do the same.  But this one is so simple that Linus
>>> hardly needs our help.
> 
> It's not about cross-tree conflicts, it's about the fact that my patch is
> a fix that needs to be backported to older kernels. It should apply cleanly
> to those older kernels if my patch goes in first, but if it is the other way
> around I would have to make a new patch for the stable kernels.

IIUC, the conflict will be resolved at merge time and the merge 
resolution will be part of the merge commit. It doesn't matter in which 
order the patches go upstream, the merge commit resolves the problematic 
overlap.

So your patch will be upstream as intended, where it can be cleanly 
backported.

Hope I am not twisting reality ;)

-- 
Thanks,

David / dhildenb
