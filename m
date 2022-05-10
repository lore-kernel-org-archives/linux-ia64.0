From: Baolin Wang <baolin.wang@linux.alibaba.com>
Date: Tue, 10 May 2022 01:28:08 +0000
Subject: Re: [PATCH 3/3] mm: rmap: Fix CONT-PTE/PMD size hugetlb issue when unmapping
Message-Id: <86671cb8-51e7-0e8e-430a-a325887391b3@linux.alibaba.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1651216964.git.baolin.wang@linux.alibaba.com>
 <c91e04ebb792ef7b72966edea8bd6fa2dfa5bfa7.1651216964.git.baolin.wang@linux.alibaba.com>
 <20220429220214.4cfc5539@thinkpad>
 <bcb4a3b0-4fcd-af3a-2a2c-fd662d9eaba9@linux.alibaba.com>
 <20220502160232.589a6111@thinkpad>
 <48a05075-a323-e7f1-9e99-6c0d106eb2cb@linux.alibaba.com>
 <20220503120343.6264e126@thinkpad>
 <927dfbf4-c899-b88a-4d58-36a637d611f9@oracle.com>
 <YnlEQvipCM6hnIYT@xz-m1.local>
In-Reply-To: <YnlEQvipCM6hnIYT@xz-m1.local>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Xu <peterx@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: Gerald Schaefer <gerald.schaefer@linux.ibm.com>, akpm@linux-foundation.org, catalin.marinas@arm.com, will@kernel.org, tsbogend@alpha.franken.de, James.Bottomley@HansenPartnership.com, deller@gmx.de, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, hca@linux.ibm.com, gor@linux.ibm.com, agordeev@linux.ibm.com, borntraeger@linux.ibm.com, svens@linux.ibm.com, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, arnd@arndb.de, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org



On 5/10/2022 12:41 AM, Peter Xu wrote:
> On Fri, May 06, 2022 at 12:07:13PM -0700, Mike Kravetz wrote:
>> On 5/3/22 03:03, Gerald Schaefer wrote:
>>> On Tue, 3 May 2022 10:19:46 +0800
>>> Baolin Wang <baolin.wang@linux.alibaba.com> wrote:
>>>> On 5/2/2022 10:02 PM, Gerald Schaefer wrote:
> 
> [...]
> 
>>>> Please see previous code, we'll use the original pte value to check if
>>>> it is uffd-wp armed, and if need to mark it dirty though the hugetlbfs
>>>> is set noop_dirty_folio().
>>>>
>>>> pte_install_uffd_wp_if_needed(vma, address, pvmw.pte, pteval);
>>>
>>> Uh, ok, that wouldn't work on s390, but we also don't have
>>> CONFIG_PTE_MARKER_UFFD_WP / HAVE_ARCH_USERFAULTFD_WP set, so
>>> I guess we will be fine (for now).
>>>
>>> Still, I find it a bit unsettling that pte_install_uffd_wp_if_needed()
>>> would work on a potential hugetlb *pte, directly de-referencing it
>>> instead of using huge_ptep_get().
>>>
>>> The !pte_none(*pte) check at the beginning would be broken in the
>>> hugetlb case for s390 (not sure about other archs, but I think s390
>>> might be the only exception strictly requiring huge_ptep_get()
>>> for de-referencing hugetlb *pte pointers).
> 
> We could have used is_vm_hugetlb_page(vma) within the helper so as to
> properly use either generic pte or hugetlb version of pte fetching.  We may
> want to conditionally do set_[huge_]pte_at() too at the end.
> 
> I could prepare a patch for that even if it's not really anything urgently
> needed. I assume that won't need to block this patchset since we need the
> pteval for pte_dirty() check anyway and uffd-wp definitely needs it too.

OK. Thanks Peter.
