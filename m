From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Fri, 19 Nov 2004 23:57:55 +0000
Subject: VM_LOCKED in pci_mmap_page_range?
Message-Id: <200411191557.55922.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Should pci_mmap_page_range marked the pages as VM_LOCKED that it's about to 
request be remapped via remap_pfn_range?  I'm seeing userspace apps hang on 
mmaping of /proc/bus/pci unless I remove it.

Thanks,
Jesse
