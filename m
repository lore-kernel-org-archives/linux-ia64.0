From: "Seth, Rohit" <rohit.seth@intel.com>
Date: Wed, 11 Aug 2004 06:36:10 +0000
Subject: RE: Hugetlb demanding paging for -mm tree
Message-Id: <01EF044AAEE12F4BAAD955CB750649430205DE92@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200408051329.i75DT3Y26431@unix-os.sc.intel.com>
In-Reply-To: <200408051329.i75DT3Y26431@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: William Lee Irwin III <wli@holomorphy.com>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, Hirokazu Takahashi <taka@valinux.co.jp>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

William Lee Irwin III <> wrote on Tuesday, August 10, 2004 5:45 PM:

> William Lee Irwin III <mailto:wli@holomorphy.com> wrote on Tuesday,
>>> Could you rephrase that? I'm having trouble figuring out what you
>>> meant.
> 
> On Tue, Aug 10, 2004 at 05:28:27PM -0700, Seth, Rohit wrote:
>> I was thinking that we only need to worry about the d-cache
>> coherency at the time of hugepage fault.  But that is not a safe
>> assumption.  You are right that we will need update_mmu_cache in the
>> hugetlb page fault path. Though I'm wondering if we can hide this
>> update_mmu_cache fucntionality behind the arch specific set_huge_pte
>> function in the demand paging patch for hugepage.  If so then we may
>> not need to make any changes in the existing update_mmu_cache API.
> 
> Most arches seem to be okay with the API, but it may be more
> useful/etc. to e.g. explicitly pass the page size, particularly when
> constant folding is possible.
> 
> 

Are you working on the patch to provide this updated API for
update_mmu_cache.

