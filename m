From: "Seth, Rohit" <rohit.seth@intel.com>
Date: Wed, 11 Aug 2004 00:28:27 +0000
Subject: RE: Hugetlb demanding paging for -mm tree
Message-Id: <01EF044AAEE12F4BAAD955CB750649430205DDE1@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200408051329.i75DT3Y26431@unix-os.sc.intel.com>
In-Reply-To: <200408051329.i75DT3Y26431@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: William Lee Irwin III <wli@holomorphy.com>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, Hirokazu Takahashi <taka@valinux.co.jp>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

William Lee Irwin III <mailto:wli@holomorphy.com> wrote on Tuesday,
August 10, 2004 1:56 AM:

> William Lee Irwin III <> wrote on Monday, August 09, 2004 11:59 AM:
>>> As things stand in mainline, it's not an obvious issue. Ken appears
>>> to be calling it for hugetlb in the ZFOD fault handling patches,
>>> which have the issue that it may behave badly in several respects
>>> when acting on large pages. The cache coherency bits in
>>> update_mmu_fault() are necessary in general, but mainline omits
>>> them. It should only result in intermittent failures on machines
>>> with sufficiently incoherent caches.
> 
> On Tue, Aug 10, 2004 at 01:52:02AM -0700, Seth, Rohit wrote:
>> Will the flush_dcache_page for hugepages even on incoherent caches be
>> not enough.  And that flush_dcache_page should be done in
>> alloc_hugepage after clearing the page(or change the clear_highpage
>> to clear_user_high_page).
> 
> Could you rephrase that? I'm having trouble figuring out what you
> meant. 
> 
> 
> -- wli

I was thinking that we only need to worry about the d-cache coherency at
the time of hugepage fault.  But that is not a safe assumption.  You are
right that we will need update_mmu_cache in the hugetlb page fault path.
Though I'm wondering if we can hide this update_mmu_cache fucntionality
behind the arch specific set_huge_pte function in the demand paging
patch for hugepage.  If so then we may not need to make any changes in
the existing update_mmu_cache API.

Thanks, rohit
