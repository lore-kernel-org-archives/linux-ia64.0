From: Andrew Morton <akpm@osdl.org>
Date: Tue, 23 Mar 2004 18:16:44 +0000
Subject: Re: 2.6.5-rc2 lots of warnings for dma_error
Message-Id: <20040323101644.472c47ae.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <5631.1079924674@kao2.melbourne.sgi.com>
In-Reply-To: <5631.1079924674@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Andrew Morton <akpm@osdl.org> wrote:
>
> > But let's put the blame where it belongs: the name space was
>  > "polluted" by introducing dma_error().  It certainly must be
>  > legal to implement basic APIs using macros.
> 
>  yes, perhaps it's not too late to change it.  Anton, what will this break?

Here's a completer patch.  I'll submit this I think.



We're getting namespace collisions from the new dma_error().  Rename it to
dma_mapping_error().


---

 25-akpm/Documentation/DMA-API.txt            |    6 +++---
 25-akpm/Documentation/DMA-mapping.txt        |    4 ++--
 25-akpm/include/asm-generic/dma-mapping.h    |    4 ++--
 25-akpm/include/asm-generic/pci-dma-compat.h |    4 ++--
 25-akpm/include/asm-i386/dma-mapping.h       |    2 +-
 25-akpm/include/asm-ppc64/pci.h              |    2 +-
 25-akpm/include/asm-sparc64/pci.h            |    2 +-
 7 files changed, 12 insertions(+), 12 deletions(-)

diff -puN Documentation/DMA-API.txt~rename-dma_error Documentation/DMA-API.txt
--- 25/Documentation/DMA-API.txt~rename-dma_error	2004-03-23 10:12:37.798413704 -0800
+++ 25-akpm/Documentation/DMA-API.txt	2004-03-23 10:12:37.808412184 -0800
@@ -279,14 +279,14 @@ recommended that you never use these unl
 cache width is.
 
 int
-dma_error(dma_addr_t dma_addr)
+dma_mapping_error(dma_addr_t dma_addr)
 
 int
-pci_dma_error(dma_addr_t dma_addr)
+pci_dma_mapping_error(dma_addr_t dma_addr)
 
 In some circumstances dma_map_single and dma_map_page will fail to create
 a mapping. A driver can check for these errors by testing the returned
-dma address with dma_error(). A non zero return value means the mapping
+dma address with dma_mapping_error(). A non zero return value means the mapping
 could not be created and the driver should take appropriate action (eg
 reduce current DMA mapping usage or delay and try again later).
 
diff -puN Documentation/DMA-mapping.txt~rename-dma_error Documentation/DMA-mapping.txt
--- 25/Documentation/DMA-mapping.txt~rename-dma_error	2004-03-23 10:12:37.799413552 -0800
+++ 25-akpm/Documentation/DMA-mapping.txt	2004-03-23 10:12:37.808412184 -0800
@@ -850,12 +850,12 @@ failure can be determined by:
 - checking if pci_alloc_consistent returns NULL or pci_map_sg returns 0
 
 - checking the returned dma_addr_t of pci_map_single and pci_map_page
-  by using pci_dma_error():
+  by using pci_dma_mapping_error():
 
 	dma_addr_t dma_handle;
 
 	dma_handle = pci_map_single(dev, addr, size, direction);
-	if (pci_dma_error(dma_handle)) {
+	if (pci_dma_mapping_error(dma_handle)) {
 		/*
 		 * reduce current DMA mapping usage,
 		 * delay and try again later or
diff -puN include/asm-generic/dma-mapping.h~rename-dma_error include/asm-generic/dma-mapping.h
--- 25/include/asm-generic/dma-mapping.h~rename-dma_error	2004-03-23 10:12:37.801413248 -0800
+++ 25-akpm/include/asm-generic/dma-mapping.h	2004-03-23 10:12:37.809412032 -0800
@@ -141,9 +141,9 @@ dma_sync_sg_for_device(struct device *de
 }
 
 static inline int
-dma_error(dma_addr_t dma_addr)
+dma_mapping_error(dma_addr_t dma_addr)
 {
-	return pci_dma_error(dma_addr);
+	return pci_dma_mapping_error(dma_addr);
 }
 
 /* Now for the API extensions over the pci_ one */
diff -puN include/asm-generic/pci-dma-compat.h~rename-dma_error include/asm-generic/pci-dma-compat.h
--- 25/include/asm-generic/pci-dma-compat.h~rename-dma_error	2004-03-23 10:12:37.803412944 -0800
+++ 25-akpm/include/asm-generic/pci-dma-compat.h	2004-03-23 10:12:37.809412032 -0800
@@ -99,9 +99,9 @@ pci_dma_sync_sg_for_device(struct pci_de
 }
 
 static inline int
-pci_dma_error(dma_addr_t dma_addr)
+pci_dma_mapping_error(dma_addr_t dma_addr)
 {
-	return dma_error(dma_addr);
+	return dma_mapping_error(dma_addr);
 }
 
 #endif
diff -puN include/asm-i386/dma-mapping.h~rename-dma_error include/asm-i386/dma-mapping.h
--- 25/include/asm-i386/dma-mapping.h~rename-dma_error	2004-03-23 10:12:37.804412792 -0800
+++ 25-akpm/include/asm-i386/dma-mapping.h	2004-03-23 10:12:37.810411880 -0800
@@ -111,7 +111,7 @@ dma_sync_sg_for_device(struct device *de
 }
 
 static inline int
-dma_error(dma_addr_t dma_addr)
+dma_mapping_error(dma_addr_t dma_addr)
 {
 	return 0;
 }
diff -puN include/asm-ppc64/pci.h~rename-dma_error include/asm-ppc64/pci.h
--- 25/include/asm-ppc64/pci.h~rename-dma_error	2004-03-23 10:12:37.806412488 -0800
+++ 25-akpm/include/asm-ppc64/pci.h	2004-03-23 10:12:37.810411880 -0800
@@ -170,7 +170,7 @@ static inline int pci_dac_dma_supported(
 }
 
 #define PCI_DMA_ERROR_CODE      (~(dma_addr_t)0x0)
-static inline int pci_dma_error(dma_addr_t dma_addr)
+static inline int pci_dma_mapping_error(dma_addr_t dma_addr)
 {
 	return (dma_addr = PCI_DMA_ERROR_CODE);
 }
diff -puN include/asm-sparc64/pci.h~rename-dma_error include/asm-sparc64/pci.h
--- 25/include/asm-sparc64/pci.h~rename-dma_error	2004-03-23 10:15:28.991388416 -0800
+++ 25-akpm/include/asm-sparc64/pci.h	2004-03-23 10:15:42.161386272 -0800
@@ -215,7 +215,7 @@ pci_dac_dma_sync_single_for_device(struc
 
 #define PCI_DMA_ERROR_CODE	(~(dma_addr_t)0x0)
 
-static inline int pci_dma_error(dma_addr_t dma_addr)
+static inline int pci_dma_mapping_error(dma_addr_t dma_addr)
 {
 	return (dma_addr = PCI_DMA_ERROR_CODE);
 }

_

