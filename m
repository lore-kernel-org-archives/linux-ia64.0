From: Tiezhu Yang <yangtiezhu@loongson.cn>
Date: Fri, 10 Dec 2021 13:36:00 +0000
Subject: [PATCH 1/2] kdump: vmcore: move copy_to() from vmcore.c to uaccess.h
Message-Id: <1639143361-17773-2-git-send-email-yangtiezhu@loongson.cn>
List-Id: <linux-ia64.vger.kernel.org>
References: <1639143361-17773-1-git-send-email-yangtiezhu@loongson.cn>
In-Reply-To: <1639143361-17773-1-git-send-email-yangtiezhu@loongson.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Young <dyoung@redhat.com>, Baoquan He <bhe@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-sh@vger.kernel.org, x86@kernel.org, linux-fsdevel@vger.kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org

In arch/*/kernel/crash_dump*.c, there exist similar code about
copy_oldmem_page(), move copy_to() from vmcore.c to uaccess.h,
and then we can use copy_to() to simplify the related code.

Signed-off-by: Tiezhu Yang <yangtiezhu@loongson.cn>
---
 fs/proc/vmcore.c        | 14 --------------
 include/linux/uaccess.h | 14 ++++++++++++++
 2 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/fs/proc/vmcore.c b/fs/proc/vmcore.c
index 509f851..c5976a8 100644
--- a/fs/proc/vmcore.c
+++ b/fs/proc/vmcore.c
@@ -238,20 +238,6 @@ copy_oldmem_page_encrypted(unsigned long pfn, char *buf, size_t csize,
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
 static int vmcoredd_copy_dumps(void *dst, u64 start, size_t size, int userbuf)
 {
diff --git a/include/linux/uaccess.h b/include/linux/uaccess.h
index ac03940..4a6c3e4 100644
--- a/include/linux/uaccess.h
+++ b/include/linux/uaccess.h
@@ -201,6 +201,20 @@ copy_to_user(void __user *to, const void *from, unsigned long n)
 	return n;
 }
 
+/*
+ * Copy to either kernel or user space
+ */
+static inline int copy_to(void *target, void *src, size_t size, int userbuf)
+{
+	if (userbuf) {
+		if (copy_to_user((char __user *) target, src, size))
+			return -EFAULT;
+	} else {
+		memcpy(target, src, size);
+	}
+	return 0;
+}
+
 #ifndef copy_mc_to_kernel
 /*
  * Without arch opt-in this generic copy_mc_to_kernel() will not handle
-- 
2.1.0
