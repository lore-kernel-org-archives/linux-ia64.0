From: Tiezhu Yang <yangtiezhu@loongson.cn>
Date: Sat, 11 Dec 2021 03:33:07 +0000
Subject: [PATCH v2 1/2] kdump: vmcore: remove copy_to() and add copy_to_user_or_kernel()
Message-Id: <1639193588-7027-2-git-send-email-yangtiezhu@loongson.cn>
List-Id: <linux-ia64.vger.kernel.org>
References: <1639193588-7027-1-git-send-email-yangtiezhu@loongson.cn>
In-Reply-To: <1639193588-7027-1-git-send-email-yangtiezhu@loongson.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Young <dyoung@redhat.com>, Baoquan He <bhe@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-sh@vger.kernel.org, x86@kernel.org, linux-fsdevel@vger.kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, Xuefeng Li <lixuefeng@loongson.cn>

In arch/*/kernel/crash_dump*.c, there exist many similar code
about copy_oldmem_page(), remove copy_to() in fs/proc/vmcore.c
and add copy_to_user_or_kernel() in lib/usercopy.c, then we can
use copy_to_user_or_kernel() to simplify the related code.

Signed-off-by: Tiezhu Yang <yangtiezhu@loongson.cn>
---
 fs/proc/vmcore.c        | 28 +++++++---------------------
 include/linux/uaccess.h |  1 +
 lib/usercopy.c          | 15 +++++++++++++++
 3 files changed, 23 insertions(+), 21 deletions(-)

diff --git a/fs/proc/vmcore.c b/fs/proc/vmcore.c
index 509f851..f67fd77 100644
--- a/fs/proc/vmcore.c
+++ b/fs/proc/vmcore.c
@@ -238,22 +238,8 @@ copy_oldmem_page_encrypted(unsigned long pfn, char *buf, size_t csize,
 	return copy_oldmem_page(pfn, buf, csize, offset, userbuf);
 }
 
-/*
- * Copy to either kernel or user space
- */
-static int copy_to(void *target, void *src, size_t size, int userbuf)
-{
-	if (userbuf) {
-		if (copy_to_user((char __user *) target, src, size))
-			return -EFAULT;
-	} else {
-		memcpy(target, src, size);
-	}
-	return 0;
-}
-
 #ifdef CONFIG_PROC_VMCORE_DEVICE_DUMP
-static int vmcoredd_copy_dumps(void *dst, u64 start, size_t size, int userbuf)
+static int vmcoredd_copy_dumps(void *dst, u64 start, size_t size, bool userbuf)
 {
 	struct vmcoredd_node *dump;
 	u64 offset = 0;
@@ -266,7 +252,7 @@ static int vmcoredd_copy_dumps(void *dst, u64 start, size_t size, int userbuf)
 		if (start < offset + dump->size) {
 			tsz = min(offset + (u64)dump->size - start, (u64)size);
 			buf = dump->buf + start - offset;
-			if (copy_to(dst, buf, tsz, userbuf)) {
+			if (copy_to_user_or_kernel(dst, buf, tsz, userbuf)) {
 				ret = -EFAULT;
 				goto out_unlock;
 			}
@@ -330,7 +316,7 @@ static int vmcoredd_mmap_dumps(struct vm_area_struct *vma, unsigned long dst,
  * returned otherwise number of bytes read are returned.
  */
 static ssize_t __read_vmcore(char *buffer, size_t buflen, loff_t *fpos,
-			     int userbuf)
+			     bool userbuf)
 {
 	ssize_t acc = 0, tmp;
 	size_t tsz;
@@ -347,7 +333,7 @@ static ssize_t __read_vmcore(char *buffer, size_t buflen, loff_t *fpos,
 	/* Read ELF core header */
 	if (*fpos < elfcorebuf_sz) {
 		tsz = min(elfcorebuf_sz - (size_t)*fpos, buflen);
-		if (copy_to(buffer, elfcorebuf + *fpos, tsz, userbuf))
+		if (copy_to_user_or_kernel(buffer, elfcorebuf + *fpos, tsz, userbuf))
 			return -EFAULT;
 		buflen -= tsz;
 		*fpos += tsz;
@@ -395,7 +381,7 @@ static ssize_t __read_vmcore(char *buffer, size_t buflen, loff_t *fpos,
 		/* Read remaining elf notes */
 		tsz = min(elfcorebuf_sz + elfnotes_sz - (size_t)*fpos, buflen);
 		kaddr = elfnotes_buf + *fpos - elfcorebuf_sz - vmcoredd_orig_sz;
-		if (copy_to(buffer, kaddr, tsz, userbuf))
+		if (copy_to_user_or_kernel(buffer, kaddr, tsz, userbuf))
 			return -EFAULT;
 
 		buflen -= tsz;
@@ -435,7 +421,7 @@ static ssize_t __read_vmcore(char *buffer, size_t buflen, loff_t *fpos,
 static ssize_t read_vmcore(struct file *file, char __user *buffer,
 			   size_t buflen, loff_t *fpos)
 {
-	return __read_vmcore((__force char *) buffer, buflen, fpos, 1);
+	return __read_vmcore((__force char *) buffer, buflen, fpos, true);
 }
 
 /*
@@ -461,7 +447,7 @@ static vm_fault_t mmap_vmcore_fault(struct vm_fault *vmf)
 	if (!PageUptodate(page)) {
 		offset = (loff_t) index << PAGE_SHIFT;
 		buf = __va((page_to_pfn(page) << PAGE_SHIFT));
-		rc = __read_vmcore(buf, PAGE_SIZE, &offset, 0);
+		rc = __read_vmcore(buf, PAGE_SIZE, &offset, false);
 		if (rc < 0) {
 			unlock_page(page);
 			put_page(page);
diff --git a/include/linux/uaccess.h b/include/linux/uaccess.h
index ac03940..a25e682e 100644
--- a/include/linux/uaccess.h
+++ b/include/linux/uaccess.h
@@ -283,6 +283,7 @@ __copy_from_user_inatomic_nocache(void *to, const void __user *from,
 #endif		/* ARCH_HAS_NOCACHE_UACCESS */
 
 extern __must_check int check_zeroed_user(const void __user *from, size_t size);
+extern __must_check int copy_to_user_or_kernel(void *target, void *src, size_t size, bool userbuf);
 
 /**
  * copy_struct_from_user: copy a struct from userspace
diff --git a/lib/usercopy.c b/lib/usercopy.c
index 7413dd3..7431b1b 100644
--- a/lib/usercopy.c
+++ b/lib/usercopy.c
@@ -90,3 +90,18 @@ int check_zeroed_user(const void __user *from, size_t size)
 	return -EFAULT;
 }
 EXPORT_SYMBOL(check_zeroed_user);
+
+/*
+ * Copy to either user or kernel space
+ */
+int copy_to_user_or_kernel(void *target, void *src, size_t size, bool userbuf)
+{
+	if (userbuf) {
+		if (copy_to_user((char __user *) target, src, size))
+			return -EFAULT;
+	} else {
+		memcpy(target, src, size);
+	}
+	return 0;
+}
+EXPORT_SYMBOL(copy_to_user_or_kernel);
-- 
2.1.0
