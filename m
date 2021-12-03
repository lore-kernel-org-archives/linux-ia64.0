From: Amit Daniel Kachhap <amit.kachhap@arm.com>
Date: Fri, 03 Dec 2021 10:54:29 +0000
Subject: [RFC PATCH 12/14] ia64/crash_dump: Use the new interface copy_oldmem_page_buf
Message-Id: <20211203104231.17597-13-amit.kachhap@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211203104231.17597-1-amit.kachhap@arm.com>
In-Reply-To: <20211203104231.17597-1-amit.kachhap@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Christoph Hellwig <hch@lst.de>, Vincenzo Frascino <Vincenzo.Frascino@arm.com>, Kevin Brodsky <kevin.brodsky@arm.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, kexec <kexec@lists.infradead.org>, Amit Daniel Kachhap <amit.kachhap@arm.com>, linux-ia64 <linux-ia64@vger.kernel.org>

The current interface copy_oldmem_page() passes user pointer without
__user annotation and hence does unnecessary user/kernel pointer
conversions during its implementation.

Use the interface copy_oldmem_page_buf() to avoid this issue.

Cc: linux-ia64 <linux-ia64@vger.kernel.org>
Signed-off-by: Amit Daniel Kachhap <amit.kachhap@arm.com>
---
 arch/ia64/kernel/crash_dump.c | 25 +++++++++++++------------
 1 file changed, 13 insertions(+), 12 deletions(-)

diff --git a/arch/ia64/kernel/crash_dump.c b/arch/ia64/kernel/crash_dump.c
index 0ed3c3dee4cd..1aea8dbe06de 100644
--- a/arch/ia64/kernel/crash_dump.c
+++ b/arch/ia64/kernel/crash_dump.c
@@ -15,37 +15,38 @@
 #include <linux/uaccess.h>
 
 /**
- * copy_oldmem_page - copy one page from "oldmem"
+ * copy_oldmem_page_buf - copy one page from "oldmem"
  * @pfn: page frame number to be copied
- * @buf: target memory address for the copy; this can be in kernel address
- *	space or user address space (see @userbuf)
+ * @ubuf: target user memory pointer for the copy; use copy_to_user() if this
+ * pointer is not NULL
+ * @kbuf: target kernel memory pointer for the copy; use memcpy() if this
+ * pointer is not NULL
  * @csize: number of bytes to copy
  * @offset: offset in bytes into the page (based on pfn) to begin the copy
- * @userbuf: if set, @buf is in user address space, use copy_to_user(),
- *	otherwise @buf is in kernel address space, use memcpy().
  *
- * Copy a page from "oldmem". For this page, there is no pte mapped
- * in the current kernel. We stitch up a pte, similar to kmap_atomic.
+ * Copy a page from "oldmem" into the buffer pointed by either @ubuf or @kbuf.
+ * For this page, there is no pte mapped in the current kernel. We stitch up a
+ * pte, similar to kmap_atomic.
  *
  * Calling copy_to_user() in atomic context is not desirable. Hence first
  * copying the data to a pre-allocated kernel page and then copying to user
  * space in non-atomic context.
  */
 ssize_t
-copy_oldmem_page(unsigned long pfn, char *buf,
-		size_t csize, unsigned long offset, int userbuf)
+copy_oldmem_page_buf(unsigned long pfn, char __user *ubuf, char *kbuf,
+		     size_t csize, unsigned long offset)
 {
 	void  *vaddr;
 
 	if (!csize)
 		return 0;
 	vaddr = __va(pfn<<PAGE_SHIFT);
-	if (userbuf) {
-		if (copy_to_user(buf, (vaddr + offset), csize)) {
+	if (ubuf) {
+		if (copy_to_user(ubuf, (vaddr + offset), csize)) {
 			return -EFAULT;
 		}
 	} else
-		memcpy(buf, (vaddr + offset), csize);
+		memcpy(kbuf, (vaddr + offset), csize);
 	return csize;
 }
 
-- 
2.17.1
