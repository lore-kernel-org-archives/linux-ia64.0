From: Tiezhu Yang <yangtiezhu@loongson.cn>
Date: Fri, 10 Dec 2021 13:36:01 +0000
Subject: [PATCH 2/2] kdump: crashdump: use copy_to() to simplify the related code
Message-Id: <1639143361-17773-3-git-send-email-yangtiezhu@loongson.cn>
List-Id: <linux-ia64.vger.kernel.org>
References: <1639143361-17773-1-git-send-email-yangtiezhu@loongson.cn>
In-Reply-To: <1639143361-17773-1-git-send-email-yangtiezhu@loongson.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Young <dyoung@redhat.com>, Baoquan He <bhe@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-sh@vger.kernel.org, x86@kernel.org, linux-fsdevel@vger.kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org

Use copy_to() to simplify the related code about copy_oldmem_page()
in arch/*/kernel/crash_dump*.c files.

Signed-off-by: Tiezhu Yang <yangtiezhu@loongson.cn>
---
 arch/arm/kernel/crash_dump.c     | 10 ++--------
 arch/arm64/kernel/crash_dump.c   | 10 ++--------
 arch/ia64/kernel/crash_dump.c    | 10 ++++------
 arch/mips/kernel/crash_dump.c    |  9 ++-------
 arch/powerpc/kernel/crash_dump.c |  7 ++-----
 arch/riscv/kernel/crash_dump.c   |  9 ++-------
 arch/sh/kernel/crash_dump.c      |  9 ++-------
 arch/x86/kernel/crash_dump_32.c  |  9 ++-------
 arch/x86/kernel/crash_dump_64.c  |  9 ++-------
 9 files changed, 20 insertions(+), 62 deletions(-)

diff --git a/arch/arm/kernel/crash_dump.c b/arch/arm/kernel/crash_dump.c
index 53cb924..6491f1d 100644
--- a/arch/arm/kernel/crash_dump.c
+++ b/arch/arm/kernel/crash_dump.c
@@ -40,14 +40,8 @@ ssize_t copy_oldmem_page(unsigned long pfn, char *buf,
 	if (!vaddr)
 		return -ENOMEM;
 
-	if (userbuf) {
-		if (copy_to_user(buf, vaddr + offset, csize)) {
-			iounmap(vaddr);
-			return -EFAULT;
-		}
-	} else {
-		memcpy(buf, vaddr + offset, csize);
-	}
+	if (copy_to(buf, vaddr + offset, csize, userbuf))
+		csize = -EFAULT;
 
 	iounmap(vaddr);
 	return csize;
diff --git a/arch/arm64/kernel/crash_dump.c b/arch/arm64/kernel/crash_dump.c
index 58303a9..496e6a5 100644
--- a/arch/arm64/kernel/crash_dump.c
+++ b/arch/arm64/kernel/crash_dump.c
@@ -38,14 +38,8 @@ ssize_t copy_oldmem_page(unsigned long pfn, char *buf,
 	if (!vaddr)
 		return -ENOMEM;
 
-	if (userbuf) {
-		if (copy_to_user((char __user *)buf, vaddr + offset, csize)) {
-			memunmap(vaddr);
-			return -EFAULT;
-		}
-	} else {
-		memcpy(buf, vaddr + offset, csize);
-	}
+	if (copy_to(buf, vaddr + offset, csize, userbuf))
+		csize = -EFAULT;
 
 	memunmap(vaddr);
 
diff --git a/arch/ia64/kernel/crash_dump.c b/arch/ia64/kernel/crash_dump.c
index 0ed3c3d..20f4c4e 100644
--- a/arch/ia64/kernel/crash_dump.c
+++ b/arch/ia64/kernel/crash_dump.c
@@ -39,13 +39,11 @@ copy_oldmem_page(unsigned long pfn, char *buf,
 
 	if (!csize)
 		return 0;
+
 	vaddr = __va(pfn<<PAGE_SHIFT);
-	if (userbuf) {
-		if (copy_to_user(buf, (vaddr + offset), csize)) {
-			return -EFAULT;
-		}
-	} else
-		memcpy(buf, (vaddr + offset), csize);
+	if (copy_to(buf, vaddr + offset, csize, userbuf))
+		return -EFAULT;
+
 	return csize;
 }
 
diff --git a/arch/mips/kernel/crash_dump.c b/arch/mips/kernel/crash_dump.c
index 2e50f551..80704dc 100644
--- a/arch/mips/kernel/crash_dump.c
+++ b/arch/mips/kernel/crash_dump.c
@@ -24,13 +24,8 @@ ssize_t copy_oldmem_page(unsigned long pfn, char *buf,
 		return 0;
 
 	vaddr = kmap_local_pfn(pfn);
-
-	if (!userbuf) {
-		memcpy(buf, vaddr + offset, csize);
-	} else {
-		if (copy_to_user(buf, vaddr + offset, csize))
-			csize = -EFAULT;
-	}
+	if (copy_to(buf, vaddr + offset, csize, userbuf))
+		csize = -EFAULT;
 
 	kunmap_local(vaddr);
 
diff --git a/arch/powerpc/kernel/crash_dump.c b/arch/powerpc/kernel/crash_dump.c
index 5693e1c67..43b2658 100644
--- a/arch/powerpc/kernel/crash_dump.c
+++ b/arch/powerpc/kernel/crash_dump.c
@@ -71,11 +71,8 @@ void __init setup_kdump_trampoline(void)
 static size_t copy_oldmem_vaddr(void *vaddr, char *buf, size_t csize,
                                unsigned long offset, int userbuf)
 {
-	if (userbuf) {
-		if (copy_to_user((char __user *)buf, (vaddr + offset), csize))
-			return -EFAULT;
-	} else
-		memcpy(buf, (vaddr + offset), csize);
+	if (copy_to(buf, vaddr + offset, csize, userbuf))
+		return -EFAULT;
 
 	return csize;
 }
diff --git a/arch/riscv/kernel/crash_dump.c b/arch/riscv/kernel/crash_dump.c
index 86cc0ad..707fbc1 100644
--- a/arch/riscv/kernel/crash_dump.c
+++ b/arch/riscv/kernel/crash_dump.c
@@ -33,13 +33,8 @@ ssize_t copy_oldmem_page(unsigned long pfn, char *buf,
 	if (!vaddr)
 		return -ENOMEM;
 
-	if (userbuf) {
-		if (copy_to_user((char __user *)buf, vaddr + offset, csize)) {
-			memunmap(vaddr);
-			return -EFAULT;
-		}
-	} else
-		memcpy(buf, vaddr + offset, csize);
+	if (copy_to(buf, vaddr + offset, csize, userbuf))
+		csize = -EFAULT;
 
 	memunmap(vaddr);
 	return csize;
diff --git a/arch/sh/kernel/crash_dump.c b/arch/sh/kernel/crash_dump.c
index 5b41b59..2af9286 100644
--- a/arch/sh/kernel/crash_dump.c
+++ b/arch/sh/kernel/crash_dump.c
@@ -33,13 +33,8 @@ ssize_t copy_oldmem_page(unsigned long pfn, char *buf,
 
 	vaddr = ioremap(pfn << PAGE_SHIFT, PAGE_SIZE);
 
-	if (userbuf) {
-		if (copy_to_user((void __user *)buf, (vaddr + offset), csize)) {
-			iounmap(vaddr);
-			return -EFAULT;
-		}
-	} else
-	memcpy(buf, (vaddr + offset), csize);
+	if (copy_to(buf, vaddr + offset, csize, userbuf))
+		csize = -EFAULT;
 
 	iounmap(vaddr);
 	return csize;
diff --git a/arch/x86/kernel/crash_dump_32.c b/arch/x86/kernel/crash_dump_32.c
index 5fcac46..731658b 100644
--- a/arch/x86/kernel/crash_dump_32.c
+++ b/arch/x86/kernel/crash_dump_32.c
@@ -54,13 +54,8 @@ ssize_t copy_oldmem_page(unsigned long pfn, char *buf, size_t csize,
 		return -EFAULT;
 
 	vaddr = kmap_local_pfn(pfn);
-
-	if (!userbuf) {
-		memcpy(buf, vaddr + offset, csize);
-	} else {
-		if (copy_to_user(buf, vaddr + offset, csize))
-			csize = -EFAULT;
-	}
+	if (copy_to(buf, vaddr + offset, csize, userbuf))
+		csize = -EFAULT;
 
 	kunmap_local(vaddr);
 
diff --git a/arch/x86/kernel/crash_dump_64.c b/arch/x86/kernel/crash_dump_64.c
index a7f617a..8e7c192 100644
--- a/arch/x86/kernel/crash_dump_64.c
+++ b/arch/x86/kernel/crash_dump_64.c
@@ -29,13 +29,8 @@ static ssize_t __copy_oldmem_page(unsigned long pfn, char *buf, size_t csize,
 	if (!vaddr)
 		return -ENOMEM;
 
-	if (userbuf) {
-		if (copy_to_user((void __user *)buf, vaddr + offset, csize)) {
-			iounmap((void __iomem *)vaddr);
-			return -EFAULT;
-		}
-	} else
-		memcpy(buf, vaddr + offset, csize);
+	if (copy_to(buf, vaddr + offset, csize, userbuf))
+		csize = -EFAULT;
 
 	set_iounmap_nonlazy();
 	iounmap((void __iomem *)vaddr);
-- 
2.1.0
