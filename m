From: Thierry Reding <thierry.reding@gmail.com>
Date: Mon, 06 Oct 2014 13:52:37 +0000
Subject: [PATCH 5/9] /dev/mem: Use more consistent data types
Message-Id: <1412603561-27653-6-git-send-email-thierry.reding@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1412603561-27653-1-git-send-email-thierry.reding@gmail.com>
In-Reply-To: <1412603561-27653-1-git-send-email-thierry.reding@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>, Olof Johansson <olof@lixom.net>, Fengguang Wu <fengguang.wu@intel.com>
Cc: Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Stephen Boyd <sboyd@codeaurora.org>, Sam Ravnborg <sam@ravnborg.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org, linux-serial@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

From: Thierry Reding <treding@nvidia.com>

The xlate_dev_{kmem,mem}_ptr() functions take either a physical address
or a kernel virtual address, so data types should be phys_addr_t and
void *. They both return a kernel virtual address which is only ever
used in calls to copy_{from,to}_user(), so make variables that store it
void * rather than char * for consistency.

Also only define a weak unxlate_dev_mem_ptr() function if architectures
haven't overridden them in the asm/io.h header file.

Signed-off-by: Thierry Reding <treding@nvidia.com>
---
 arch/s390/include/asm/io.h |  5 +++--
 arch/s390/mm/maccess.c     |  4 ++--
 arch/x86/include/asm/io.h  |  4 ++--
 arch/x86/mm/ioremap.c      |  4 ++--
 drivers/char/mem.c         | 13 ++++++++-----
 5 files changed, 17 insertions(+), 13 deletions(-)

diff --git a/arch/s390/include/asm/io.h b/arch/s390/include/asm/io.h
index cd6b9ee7b69c..d22c2eeae78f 100644
--- a/arch/s390/include/asm/io.h
+++ b/arch/s390/include/asm/io.h
@@ -13,9 +13,10 @@
 #include <asm/page.h>
 #include <asm/pci_io.h>
 
-void *xlate_dev_mem_ptr(unsigned long phys);
 #define xlate_dev_mem_ptr xlate_dev_mem_ptr
-void unxlate_dev_mem_ptr(unsigned long phys, void *addr);
+void *xlate_dev_mem_ptr(phys_addr_t phys);
+#define unxlate_dev_mem_ptr unxlate_dev_mem_ptr
+void unxlate_dev_mem_ptr(phys_addr_t phys, void *addr);
 
 /*
  * Convert a virtual cached pointer to an uncached pointer
diff --git a/arch/s390/mm/maccess.c b/arch/s390/mm/maccess.c
index 2a2e35416d2f..2eb34bdfc613 100644
--- a/arch/s390/mm/maccess.c
+++ b/arch/s390/mm/maccess.c
@@ -176,7 +176,7 @@ static int is_swapped(unsigned long addr)
  * For swapped prefix pages a new buffer is returned that contains a copy of
  * the absolute memory. The buffer size is maximum one page large.
  */
-void *xlate_dev_mem_ptr(unsigned long addr)
+void *xlate_dev_mem_ptr(phys_addr_t addr)
 {
 	void *bounce = (void *) addr;
 	unsigned long size;
@@ -197,7 +197,7 @@ void *xlate_dev_mem_ptr(unsigned long addr)
 /*
  * Free converted buffer for /dev/mem access (if necessary)
  */
-void unxlate_dev_mem_ptr(unsigned long addr, void *buf)
+void unxlate_dev_mem_ptr(phys_addr_t addr, void *buf)
 {
 	if ((void *) addr != buf)
 		free_page((unsigned long) buf);
diff --git a/arch/x86/include/asm/io.h b/arch/x86/include/asm/io.h
index b8237d8a1e0c..ae2b593e7c6e 100644
--- a/arch/x86/include/asm/io.h
+++ b/arch/x86/include/asm/io.h
@@ -310,8 +310,8 @@ BUILDIO(b, b, char)
 BUILDIO(w, w, short)
 BUILDIO(l, , int)
 
-extern void *xlate_dev_mem_ptr(unsigned long phys);
-extern void unxlate_dev_mem_ptr(unsigned long phys, void *addr);
+extern void *xlate_dev_mem_ptr(phys_addr_t phys);
+extern void unxlate_dev_mem_ptr(phys_addr_t phys, void *addr);
 
 extern int ioremap_change_attr(unsigned long vaddr, unsigned long size,
 				unsigned long prot_val);
diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
index af78e50ca6ce..b12f43c192cf 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -327,7 +327,7 @@ EXPORT_SYMBOL(iounmap);
  * Convert a physical pointer to a virtual kernel pointer for /dev/mem
  * access
  */
-void *xlate_dev_mem_ptr(unsigned long phys)
+void *xlate_dev_mem_ptr(phys_addr_t phys)
 {
 	void *addr;
 	unsigned long start = phys & PAGE_MASK;
@@ -343,7 +343,7 @@ void *xlate_dev_mem_ptr(unsigned long phys)
 	return addr;
 }
 
-void unxlate_dev_mem_ptr(unsigned long phys, void *addr)
+void unxlate_dev_mem_ptr(phys_addr_t phys, void *addr)
 {
 	if (page_is_ram(phys >> PAGE_SHIFT))
 		return;
diff --git a/drivers/char/mem.c b/drivers/char/mem.c
index 524b707894ef..4c58333b4257 100644
--- a/drivers/char/mem.c
+++ b/drivers/char/mem.c
@@ -84,9 +84,12 @@ static inline int range_is_allowed(unsigned long pfn, unsigned long size)
 }
 #endif
 
-void __weak unxlate_dev_mem_ptr(unsigned long phys, void *addr)
+#ifndef unxlate_dev_mem_ptr
+#define unxlate_dev_mem_ptr unxlate_dev_mem_ptr
+void __weak unxlate_dev_mem_ptr(phys_addr_t phys, void *addr)
 {
 }
+#endif
 
 /*
  * This funcion reads the *physical* memory. The f_pos points directly to the
@@ -97,7 +100,7 @@ static ssize_t read_mem(struct file *file, char __user *buf,
 {
 	phys_addr_t p = *ppos;
 	ssize_t read, sz;
-	char *ptr;
+	void *ptr;
 
 	if (p != *ppos)
 		return 0;
@@ -400,7 +403,7 @@ static ssize_t read_kmem(struct file *file, char __user *buf,
 			 * uncached, then it must also be accessed uncached
 			 * by the kernel or data corruption may occur
 			 */
-			kbuf = xlate_dev_kmem_ptr((char *)p);
+			kbuf = xlate_dev_kmem_ptr((void *)p);
 
 			if (copy_to_user(buf, kbuf, sz))
 				return -EFAULT;
@@ -461,7 +464,7 @@ static ssize_t do_write_kmem(unsigned long p, const char __user *buf,
 #endif
 
 	while (count > 0) {
-		char *ptr;
+		void *ptr;
 
 		sz = size_inside_page(p, count);
 
@@ -470,7 +473,7 @@ static ssize_t do_write_kmem(unsigned long p, const char __user *buf,
 		 * it must also be accessed uncached by the kernel or data
 		 * corruption may occur.
 		 */
-		ptr = xlate_dev_kmem_ptr((char *)p);
+		ptr = xlate_dev_kmem_ptr((void *)p);
 
 		copied = copy_from_user(ptr, buf, sz);
 		if (copied) {
-- 
2.1.0

