From: David Woodhouse <dwmw2@infradead.org>
Date: Wed, 05 Aug 2009 07:23:09 +0000
Subject: Re: [PATCH 3/4] Bug Fix drivers/pci/intel-iommu.c: convert paddr
Message-Id: <1249456989.9324.339.camel@macbook.infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <bug-504363-150293@bugzilla.redhat.com>
	 <200908042017.n74KHsNw018095@bz-web1.app.phx.redhat.com>
	 <20090804221058.GA21448@linux-os.sc.intel.com>
In-Reply-To: <20090804221058.GA21448@linux-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Fenghua Yu <fenghua.yu@intel.com>
Cc: Tony Luck <tony.luck@intel.com>, iommu@lists.linux-foundation.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, 2009-08-04 at 15:10 -0700, Fenghua Yu wrote:
> When calling domain_pfn_mapping(), paddr should be converted to DMA pfn
> correctly instead just shift by VTD_PAGE_SHIFT.
> 
> This issue causes kernel panic on PAGE_SIZE>VTD_PAGE_SIZE platforms e.g. ia64
> platforms.
> 
> Signed-off-by: Fenghua Yu <fenghua.yu@intel.com>

Using the word 'alignment' somewhere in the above commit would have
confused me a lot less -- I got most of the way through composing a mail
asking how this patch wasn't a no-op, before I spotted it.

An alternative would be to align the size to DMA pages? Would that make
the sg case easier? 

(Thanks for fixing this, btw)

-- 
dwmw2

