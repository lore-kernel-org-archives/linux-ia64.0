From: "Yu, Fenghua" <fenghua.yu@intel.com>
Date: Sat, 04 Oct 2008 00:53:04 +0000
Subject: RE: [PATCH 2/2]Add Variable Page Size and IA64 Support in Intel
Message-Id: <A6AD88C3F2289247BE726C37303E1EB8844A6398@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081001165750.GA21272@linux-os.sc.intel.com>
 <200810020951.08408.bjorn.helgaas@hp.com>
 <A6AD88C3F2289247BE726C37303E1EB88408AA3E@orsmsx505.amr.corp.intel.com>
 <200810030941.42800.bjorn.helgaas@hp.com>
In-Reply-To: <200810030941.42800.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Jesse Barnes <jbarnes@virtuousgeek.org>, David Woodhouse <dwmw2@infradead.org>, Ingo Molnar <mingo@elte.hu>, Avi Kivity <avi@redhat.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

>> >This patch adds clflush_cache_range(), but it's not used anywhere.
>> Clflush_cache_range() is used in __iommu_flush_cache() in include/linux/intel-iommu.h.

>Oh, OK.  I didn't look hard enough to find __iommu_flush_cache()
> (currently in drivers/pci/intel-iommu.c).

>Architecturally, I'm surprised that ia64 would need to actually do a
>cache flush.  I would think the VT-d hardware would do coherent accesses
>which would make the cache flush unnecessary.

VT-d hardware supports both non cache coherency and cache coherency by bit Coherency in Extended Capabilities Register.

Could you please point me to the doc that explicitly says that architecturally ia64 doesn't need cache flush?

Thanks.

-Fenghua
