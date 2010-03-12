From: Albert Herranz <albert_herranz@yahoo.es>
Date: Fri, 12 Mar 2010 19:12:40 +0000
Subject: [PATCH v4 05/11] swiotlb: add swiotlb_set_default_size()
Message-Id: <1268421166-4791-6-git-send-email-albert_herranz@yahoo.es>
List-Id: <linux-ia64.vger.kernel.org>
References: <1268421166-4791-1-git-send-email-albert_herranz@yahoo.es>
In-Reply-To: <1268421166-4791-1-git-send-email-albert_herranz@yahoo.es>
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

CC: linuxppc-dev@lists.ozlabs.org
CC: linux-kernel@vger.kernel.org
CC: x86@kernel.org
CC: linux-ia64@vger.kernel.org
Signed-off-by: Albert Herranz <albert_herranz@yahoo.es>
---
 include/linux/swiotlb.h |    2 ++
 lib/swiotlb.c           |   20 ++++++++++++++++++++
 2 files changed, 22 insertions(+), 0 deletions(-)

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
index 8f2dad9..dbeca50 100644
--- a/lib/swiotlb.c
+++ b/lib/swiotlb.c
@@ -117,6 +117,26 @@ setup_io_tlb_npages(char *str)
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
+	size_t previous_size = io_tlb_nslabs << IO_TLB_SHIFT;
+
+	io_tlb_nslabs = size >> IO_TLB_SHIFT;
+	return previous_size;
+}
+
 void * __weak __init swiotlb_alloc_boot(size_t size, unsigned long nslabs)
 {
 	return alloc_bootmem_low_pages(size);
-- 
1.6.3.3

