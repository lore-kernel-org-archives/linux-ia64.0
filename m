From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 15 Dec 2004 17:53:32 +0000
Subject: virtual memmap and page_address
Message-Id: <200412150953.32812.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I've been messing around with some of the drm drivers lately, and in some 
cases they'll call pci_map_single on an address returned from page_address().  
When virtual memmaps are enabled, page_address will return a region 5 
pointer.  It looks like all of the ia64 iommu code (swiotlb, sba_iommu and 
sn2's pci_dma) assume that the address passed in is an identity mapped 
address since they use __pa to get the physical address.  This is fast, but 
also incorrect when the routines are handed a region 5 address.  So we either 
have to fix our iommu mapping routines or change some other assumptions 
(either about what page_address should return or what __va in general means 
for example).  Turning on WANT_PAGE_VIRTUAL and populating page->virtual with 
an identity mapped address is another option, probably less expensive than 
switching to ia64_tpa in the mapping routines.

Comments?

Thanks,
Jesse
