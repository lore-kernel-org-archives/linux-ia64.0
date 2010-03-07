From: Albert Herranz <albert_herranz@yahoo.es>
Date: Sun, 07 Mar 2010 12:11:46 +0000
Subject: [RFC PATCH v3 05/11] swiotlb: add swiotlb_set_default_size()
Message-Id: <1267963912-984-6-git-send-email-albert_herranz@yahoo.es>
List-Id: <linux-ia64.vger.kernel.org>
References: <1267963912-984-1-git-send-email-albert_herranz@yahoo.es>
In-Reply-To: <1267963912-984-1-git-send-email-albert_herranz@yahoo.es>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-usb@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Cc: Albert Herranz <albert_herranz@yahoo.es>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org

The current SWIOTLB code uses a default of 64MB for the IO TLB area.
This size can be influenced using a kernel command line parameter "swiotlb".
Unfortunately, the parsing of the kernel command line is done _after_ the
swiotlb is initialized on some architectures.

This patch adds a new function swiotlb_set_default_size() which can be used
before swiotlb_init() to indicate the desired IO TLB area size in bytes.

This will be used later to implement a smaller IO TLB on the Nintendo Wii
video game console which just comes with 24MB + 64MB of RAM.

Signed-off-by: Albert Herranz <albert_herranz@yahoo.es>
CC: linuxppc-dev@lists.ozlabs.org
CC: linux-kernel@vger.kernel.org
CC: x86@kernel.org
CC: linux-ia64@vger.kernel.org
---
 include/linux/swiotlb.h |    2 ++
 lib/swiotlb.c           |   27 ++++++++++++++++++++++++++-
 2 files changed, 28 insertions(+), 1 deletions(-)

diff --git a/include/linux/swiotlb.h b/include/linux/swiotlb.h
index 3954228..2af6a45 100644
--- a/include/linux/swiotlb.h
+++ b/include/linux/swiotlb.h
@@ -22,6 +22,8 @@ extern int swiotlb_force;
  */
 #define IO_TLB_SHIFT 11
 
+extern size_t __init swiotlb_set_default_size(size_t size);
+
 extern void swiotlb_init(int verbose);
 
 extern void *swiotlb_alloc_boot(size_t bytes, unsigned long nslabs);
diff --git a/lib/swiotlb.c b/lib/swiotlb.c
index 8f2dad9..c99512d 100644
--- a/lib/swiotlb.c
+++ b/lib/swiotlb.c
@@ -73,6 +73,11 @@ static char *io_tlb_start, *io_tlb_end;
 static unsigned long io_tlb_nslabs;
 
 /*
+ * Default size for the IO TLB (64MB).
+ */
+static __initdata size_t io_tlb_default_size = 64 * (1<<20);
+
+/*
  * When the IOMMU overflows we return a fallback buffer. This sets the size.
  */
 static unsigned long io_tlb_overflow = 32*1024;
@@ -117,6 +122,26 @@ setup_io_tlb_npages(char *str)
 __setup("swiotlb=", setup_io_tlb_npages);
 /* make io_tlb_overflow tunable too? */
 
+/**
+ * swiotlb_set_default_size() - set the default size for the IO TLB
+ * @size:	size in bytes of the IO TLB
+ *
+ * A platform can use this function to change the default size of the
+ * IO TLB when the default of 64MB is not suitable.
+ * This function must be called before swiotlb_init().
+ *
+ * Note that on some platforms this is the only way to influence the
+ * size of the IO TLB, as the command line may be parsed _after_ the
+ * IO TLB is initialized.
+ */
+size_t __init swiotlb_set_default_size(size_t size)
+{
+	size_t previous_size = io_tlb_default_size;
+
+	io_tlb_default_size = size;
+	return previous_size;
+}
+
 void * __weak __init swiotlb_alloc_boot(size_t size, unsigned long nslabs)
 {
 	return alloc_bootmem_low_pages(size);
@@ -193,7 +218,7 @@ swiotlb_init_with_default_size(size_t default_size, int verbose)
 void __init
 swiotlb_init(int verbose)
 {
-	swiotlb_init_with_default_size(64 * (1<<20), verbose);	/* default to 64MB */
+	swiotlb_init_with_default_size(io_tlb_default_size, verbose);
 }
 
 /*
-- 
1.6.3.3

