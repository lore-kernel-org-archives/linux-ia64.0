From: Vlastimil Babka <vbabka@suse.cz>
Date: Tue, 22 Nov 2022 16:29:16 +0000
Subject: Re: [PATCH mm-unstable v1 09/20] mm/gup: reliable R/O long-term pinning in COW mappings
Message-Id: <8bb93984-a2f4-2029-7cec-bea659e77b6c@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221116102659.70287-1-david@redhat.com>
 <20221116102659.70287-10-david@redhat.com>
In-Reply-To: <20221116102659.70287-10-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>, linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, etnaviv@lists.freedesktop.org, dri-devel@lists.freedesktop.org, linux-samsung-soc@vger.kernel.org, linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-perf-users@vger.kernel.org, linux-security-module@vger.kernel.org, linux-kselftest@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jason Gunthorpe <jgg@ziepe.ca>, John Hubbard <jhubbard@nvidia.com>, Peter Xu <peterx@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Nadav Amit <namit@vmware.com>, Matthew Wilcox <willy@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>, Muchun Song <songmuchun@bytedance.com>, Shuah Khan <shuah@kernel.org>, Lucas Stach <l.stach@pengutronix.de>, David Airlie <airlied@gmail.com>, Oded Gabbay <ogabbay@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Christoph Hellwig <hch@infradead.org>, Alex Williamson <alex.williamson@redhat.com>

On 11/16/22 11:26, David Hildenbrand wrote:
> We already support reliable R/O pinning of anonymous memory. However,
> assume we end up pinning (R/O long-term) a pagecache page or the shared
> zeropage inside a writable private ("COW") mapping. The next write access
> will trigger a write-fault and replace the pinned page by an exclusive
> anonymous page in the process page tables to break COW: the pinned page no
> longer corresponds to the page mapped into the process' page table.
> 
> Now that FAULT_FLAG_UNSHARE can break COW on anything mapped into a
> COW mapping, let's properly break COW first before R/O long-term
> pinning something that's not an exclusive anon page inside a COW
> mapping. FAULT_FLAG_UNSHARE will break COW and map an exclusive anon page
> instead that can get pinned safely.
> 
> With this change, we can stop using FOLL_FORCE|FOLL_WRITE for reliable
> R/O long-term pinning in COW mappings.
> 
> With this change, the new R/O long-term pinning tests for non-anonymous
> memory succeed:
>   # [RUN] R/O longterm GUP pin ... with shared zeropage
>   ok 151 Longterm R/O pin is reliable
>   # [RUN] R/O longterm GUP pin ... with memfd
>   ok 152 Longterm R/O pin is reliable
>   # [RUN] R/O longterm GUP pin ... with tmpfile
>   ok 153 Longterm R/O pin is reliable
>   # [RUN] R/O longterm GUP pin ... with huge zeropage
>   ok 154 Longterm R/O pin is reliable
>   # [RUN] R/O longterm GUP pin ... with memfd hugetlb (2048 kB)
>   ok 155 Longterm R/O pin is reliable
>   # [RUN] R/O longterm GUP pin ... with memfd hugetlb (1048576 kB)
>   ok 156 Longterm R/O pin is reliable
>   # [RUN] R/O longterm GUP-fast pin ... with shared zeropage
>   ok 157 Longterm R/O pin is reliable
>   # [RUN] R/O longterm GUP-fast pin ... with memfd
>   ok 158 Longterm R/O pin is reliable
>   # [RUN] R/O longterm GUP-fast pin ... with tmpfile
>   ok 159 Longterm R/O pin is reliable
>   # [RUN] R/O longterm GUP-fast pin ... with huge zeropage
>   ok 160 Longterm R/O pin is reliable
>   # [RUN] R/O longterm GUP-fast pin ... with memfd hugetlb (2048 kB)
>   ok 161 Longterm R/O pin is reliable
>   # [RUN] R/O longterm GUP-fast pin ... with memfd hugetlb (1048576 kB)
>   ok 162 Longterm R/O pin is reliable
> 
> Note 1: We don't care about short-term R/O-pinning, because they have
> snapshot semantics: they are not supposed to observe modifications that
> happen after pinning.
> 
> As one example, assume we start direct I/O to read from a page and store
> page content into a file: modifications to page content after starting
> direct I/O are not guaranteed to end up in the file. So even if we'd pin
> the shared zeropage, the end result would be as expected -- getting zeroes
> stored to the file.
> 
> Note 2: For shared mappings we'll now always fallback to the slow path to
> lookup the VMA when R/O long-term pining. While that's the necessary price
> we have to pay right now, it's actually not that bad in practice: most
> FOLL_LONGTERM users already specify FOLL_WRITE, for example, along with
> FOLL_FORCE because they tried dealing with COW mappings correctly ...
> 
> Note 3: For users that use FOLL_LONGTERM right now without FOLL_WRITE,
> such as VFIO, we'd now no longer pin the shared zeropage. Instead, we'd
> populate exclusive anon pages that we can pin. There was a concern that
> this could affect the memlock limit of existing setups.
> 
> For example, a VM running with VFIO could run into the memlock limit and
> fail to run. However, we essentially had the same behavior already in
> commit 17839856fd58 ("gup: document and work around "COW can break either
> way" issue") which got merged into some enterprise distros, and there were
> not any such complaints. So most probably, we're fine.
> 
> Signed-off-by: David Hildenbrand <david@redhat.com>

Reviewed-by: Vlastimil Babka <vbabka@suse.cz>
