From: William Lee Irwin III <wli@holomorphy.com>
Date: Sat, 07 Aug 2004 08:13:11 +0000
Subject: Re: Hugetlb demanding paging for -mm tree
Message-Id: <20040807081311.GY17188@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040806.013522.74731251.taka@valinux.co.jp> <200408062055.i76KtcY08296@unix-os.sc.intel.com> <20040806210750.GT17188@holomorphy.com>
In-Reply-To: <20040806210750.GT17188@holomorphy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, 'Hirokazu Takahashi' <taka@valinux.co.jp>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, "Seth, Rohit" <rohit.seth@intel.com>

On Fri, Aug 06, 2004 at 02:07:50PM -0700, William Lee Irwin III wrote:
> update_mmu_cache() does not appear to check the size of the translation
> to be established in many architectures. e.g. on arch/ia64/ it does
> flush_icache_range(addr, addr + PAGE_SIZE) unconditionally, and only
> sets PG_arch_1 on a single struct page. Similar comments apply to
> sparc64 and ppc64; I didn't check any others.

In general not much seems to be getting done about cache coherency in
hugetlb at all. This may be problematic even in mainline.


-- wli
