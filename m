From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 25 Oct 2001 05:26:37 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.13)
Message-Id: <marc-linux-ia64-105590698805391@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 24 Oct 2001 21:30:42 -0700, 
David Mosberger <davidm@hpl.hp.com> wrote:
>An updated ia64 patch for 2.4.13 is now available at
>This kernel has been tested with gcc-3.0 on Big Sur, Lion, and HP
>simulator.  Both UP and MP seem to compile fine.  As usual, your
>mileage may vary.

Not many miles for me ;)

Index: 13.3/include/asm-ia64/pci.h
--- 13.3/include/asm-ia64/pci.h Thu, 25 Oct 2001 15:06:28 +1000 kaos (linux-2.4/t/2_pci.h 1.4 644)
+++ 13.3(w)/include/asm-ia64/pci.h Thu, 25 Oct 2001 15:25:33 +1000 kaos (linux-2.4/t/2_pci.h 1.4 644)
@@ -60,7 +60,7 @@ pci_dma_supported (struct pci_dev *hwdev
 #define pci_map_page(dev,pg,off,size,dir)				\
 	pci_map_single((dev), page_address(pg) + (off), (size), (dir))
 #define pci_unmap_page(dev,dma_addr,size,dir)				\
-	pci_unmap_single((dev), (dma_addr), (size), (dir)
+	pci_unmap_single((dev), (dma_addr), (size), (dir))
 
 /* The ia64 platform always supports 64-bit addressing. */
 #define pci_dac_dma_supported(pci_dev, mask)	(1)


