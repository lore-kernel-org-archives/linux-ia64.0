From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 10 May 2022 04:04:04 +0000
Subject: Re: [PATCH v3 0/3] Fix CONT-PTE/PMD size hugetlb issue when unmapping or migrating
Message-Id: <20220509210404.6a43aff15d0d6b3af0741001@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1652147571.git.baolin.wang@linux.alibaba.com>
In-Reply-To: <cover.1652147571.git.baolin.wang@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Baolin Wang <baolin.wang@linux.alibaba.com>
Cc: mike.kravetz@oracle.com, catalin.marinas@arm.com, will@kernel.org, songmuchun@bytedance.com, tsbogend@alpha.franken.de, James.Bottomley@HansenPartnership.com, deller@gmx.de, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, hca@linux.ibm.com, gor@linux.ibm.com, agordeev@linux.ibm.com, borntraeger@linux.ibm.com, svens@linux.ibm.com, ysato@users.osdn.me, dalias@libc.org, davem@davemloft.net, arnd@arndb.de, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Tue, 10 May 2022 11:45:57 +0800 Baolin Wang <baolin.wang@linux.alibaba.com> wrote:

> Hi,
> 
> Now migrating a hugetlb page or unmapping a poisoned hugetlb page, we'll
> use ptep_clear_flush() and set_pte_at() to nuke the page table entry
> and remap it, and this is incorrect for CONT-PTE or CONT-PMD size hugetlb
> page,

It would be helpful to describe why it's wrong.  Something like "should
use huge_ptep_clear_flush() and huge_ptep_clear_flush() for this
purpose"?

> which will cause potential data consistent issue. This patch set
> will change to use hugetlb related APIs to fix this issue, please find
> details in each patch. Thanks.

Is a cc:stable needed here?  And are we able to identify a target for a
Fixes: tag?

