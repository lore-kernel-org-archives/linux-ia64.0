From: William Lee Irwin III <wli@holomorphy.com>
Date: Mon, 09 Aug 2004 18:59:28 +0000
Subject: Re: Hugetlb demanding paging for -mm tree
Message-Id: <20040809185928.GR11200@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <01EF044AAEE12F4BAAD955CB7506494302005232@scsmsx401.amr.corp.intel.com>
In-Reply-To: <01EF044AAEE12F4BAAD955CB7506494302005232@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Seth, Rohit" <rohit.seth@intel.com>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, Hirokazu Takahashi <taka@valinux.co.jp>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Chen, Kenneth W <mailto:kenneth.w.chen@intel.com> wrote on Monday,
>> I suppose this is fixable in update_mmu_cache() where it can check the
>> type of pte and do appropriate sizing and other things.  ia64 would
>> have 
>> to check the address instead of looking at the pte.

On Mon, Aug 09, 2004 at 11:43:32AM -0700, Seth, Rohit wrote:
> Why do we need update_mmu_cache for hugepages?

As things stand in mainline, it's not an obvious issue. Ken appears to
be calling it for hugetlb in the ZFOD fault handling patches, which
have the issue that it may behave badly in several respects when acting
on large pages. The cache coherency bits in update_mmu_fault() are
necessary in general, but mainline omits them. It should only result in
intermittent failures on machines with sufficiently incoherent caches.


-- wli
