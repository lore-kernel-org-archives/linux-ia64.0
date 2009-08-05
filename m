From: David Woodhouse <dwmw2@infradead.org>
Date: Wed, 05 Aug 2009 08:09:59 +0000
Subject: Re: [PATCH 2/4] Bug Fix drivers/pci/intel-iommu.c: secure
Message-Id: <1249459799.9324.348.camel@macbook.infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <BAE9DCEF64577A439B3A37F36F9B691C0339372B@orsmsx418.amr.corp.intel.com>
	 <617E1C2C70743745A92448908E030B2A02AD5AD7@scsmsx411.amr.corp.intel.com>
	 <20090804221024.GA21406@linux-os.sc.intel.com>
In-Reply-To: <20090804221024.GA21406@linux-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Fenghua Yu <fenghua.yu@intel.com>
Cc: Tony Luck <tony.luck@intel.com>, iommu@lists.linux-foundation.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, 2009-08-04 at 15:10 -0700, Fenghua Yu wrote:
> sg_next() is called only when sg is not NULL. This solves a kernel panic on
> some platforms (e.g. ia64).

Is this still necessary after we fix the other bugs? When does it
happen? And is this fix sufficient (ignore the first hunk; it's just a
cleanup that the fix allows me to make, which is why I'd prefer to do it
this way):

diff --git a/drivers/pci/intel-iommu.c b/drivers/pci/intel-iommu.c
index 11b317a..c9bdb0b 100644
--- a/drivers/pci/intel-iommu.c
+++ b/drivers/pci/intel-iommu.c
@@ -1675,7 +1675,7 @@ static int __domain_mapping(struct dmar_domain *domain, unsigned long iov_pfn,
 	if (sg)
 		sg_res = 0;
 	else {
-		sg_res = nr_pages + 1;
+		sg_res = nr_pages;
 		pteval = ((phys_addr_t)phys_pfn << VTD_PAGE_SHIFT) | prot;
 	}
 
@@ -1716,7 +1716,7 @@ static int __domain_mapping(struct dmar_domain *domain, unsigned long iov_pfn,
 		iov_pfn++;
 		pteval += VTD_PAGE_SIZE;
 		sg_res--;
-		if (!sg_res)
+		if (nr_pages && !sg_res)
 			sg = sg_next(sg);
 	}
 	return 0;


-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

