From: William Lee Irwin III <wli@holomorphy.com>
Date: Wed, 11 Aug 2004 00:45:27 +0000
Subject: Re: Hugetlb demanding paging for -mm tree
Message-Id: <20040811004527.GJ11200@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <01EF044AAEE12F4BAAD955CB750649430205DDE1@scsmsx401.amr.corp.intel.com>
In-Reply-To: <01EF044AAEE12F4BAAD955CB750649430205DDE1@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Seth, Rohit" <rohit.seth@intel.com>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, Hirokazu Takahashi <taka@valinux.co.jp>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

William Lee Irwin III <mailto:wli@holomorphy.com> wrote on Tuesday,
>> Could you rephrase that? I'm having trouble figuring out what you
>> meant. 

On Tue, Aug 10, 2004 at 05:28:27PM -0700, Seth, Rohit wrote:
> I was thinking that we only need to worry about the d-cache coherency at
> the time of hugepage fault.  But that is not a safe assumption.  You are
> right that we will need update_mmu_cache in the hugetlb page fault path.
> Though I'm wondering if we can hide this update_mmu_cache fucntionality
> behind the arch specific set_huge_pte function in the demand paging
> patch for hugepage.  If so then we may not need to make any changes in
> the existing update_mmu_cache API.

Most arches seem to be okay with the API, but it may be more useful/etc.
to e.g. explicitly pass the page size, particularly when constant
folding is possible.


-- wli
