From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 23 Oct 2003 17:01:40 +0000
Subject: Re: PATCH 2.4.23-pre6 add kmap_types.h for CONFIG_CRYPTO
Message-Id: <marc-linux-ia64-106692855211212@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106633278923482@msgid-missing>
In-Reply-To: <marc-linux-ia64-106633278923482@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here's my proposal for a fix.  I don't think I'll send it to Linus/Andrew
yet, because it's really a cleanup, not an actual bug fix, but here it
is for any comments.

Bjorn




Currently every architecture must supply kmap_types.h, even though
it only makes sense for architectures that use highmem.

This patch removes the need for generic code to know about kmap_types.h
by adding the appropriate #include to include/linux/highmem.h and
defining a minimal set of KM_ enums that are used by generic code.

One might argue that we shouldn't need to define even the minimal
set of KM_ enums, but generic code needs to be able to do, for
example:

	kmap_atomic(page, KM_USER);

In many cases the KM_USER needn't be defined at all because the
non-highmem kmap_atomic() never evaluates it, but leaving it
undefined also restricts generic code from doing other things
like defining an array of KM_ types.  crypto/cipher.c defines
such an array, and it seems non-intuitive to prevent that usage.

This allows the removal of the following dummy kmap_types.h files: 

	include/asm-alpha/kmap_types.h
	include/asm-arm/kmap_types.h
	include/asm-arm26/kmap_types.h
	include/asm-cris/kmap_types.h
	include/asm-h8300/kmap_types.h
	include/asm-ia64/kmap_types.h
	include/asm-m68k/kmap_types.h
	include/asm-m68knommu/kmap_types.h
	include/asm-parisc/kmap_types.h
	include/asm-ppc64/kmap_types.h
	include/asm-s390/kmap_types.h
	include/asm-sh/kmap_types.h
	include/asm-sparc64/kmap_types.h
	include/asm-v850/kmap_types.h
	include/asm-x86_64/kmap_types.h

This is against 2.6 and has been boot tested on ia64 and x86.

Bjorn


# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1368  -> 1.1369 
#	include/asm-m68knommu/kmap_types.h	1.1     ->         (deleted)      
#	   crypto/internal.h	1.19    -> 1.20   
#	include/asm-m68k/kmap_types.h	1.3     ->         (deleted)      
#	include/asm-v850/kmap_types.h	1.1     ->         (deleted)      
#	include/asm-cris/kmap_types.h	1.1     ->         (deleted)      
#	include/asm-arm26/kmap_types.h	1.1     ->         (deleted)      
#	            fs/aio.c	1.37    -> 1.38   
#	include/asm-sh/kmap_types.h	1.1     ->         (deleted)      
#	include/asm-ia64/kmap_types.h	1.5     ->         (deleted)      
#	include/asm-ppc64/kmap_types.h	1.4     ->         (deleted)      
#	include/asm-parisc/kmap_types.h	1.3     ->         (deleted)      
#	include/asm-s390/kmap_types.h	1.4     ->         (deleted)      
#	include/asm-h8300/kmap_types.h	1.1     ->         (deleted)      
#	include/asm-x86_64/kmap_types.h	1.7     ->         (deleted)      
#	include/linux/highmem.h	1.27    -> 1.28   
#	include/asm-sparc64/kmap_types.h	1.4     ->         (deleted)      
#	include/asm-arm/kmap_types.h	1.1     ->         (deleted)      
#	include/asm-alpha/kmap_types.h	1.5     ->         (deleted)      
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/10/23	bjorn.helgaas@hp.com	1.1369
# Remove dummy kmap_types.h files.  Only architectures that use highmem
# really need those files.
# --------------------------------------------
#
diff -Nru a/crypto/internal.h b/crypto/internal.h
--- a/crypto/internal.h	Thu Oct 23 10:54:38 2003
+++ b/crypto/internal.h	Thu Oct 23 10:54:38 2003
@@ -17,7 +17,6 @@
 #include <linux/init.h>
 #include <linux/kmod.h>
 #include <asm/hardirq.h>
-#include <asm/kmap_types.h>
 
 extern enum km_type crypto_km_types[];
 
diff -Nru a/fs/aio.c b/fs/aio.c
--- a/fs/aio.c	Thu Oct 23 10:54:38 2003
+++ b/fs/aio.c	Thu Oct 23 10:54:38 2003
@@ -28,7 +28,6 @@
 #include <linux/highmem.h>
 #include <linux/workqueue.h>
 
-#include <asm/kmap_types.h>
 #include <asm/uaccess.h>
 #include <asm/mmu_context.h>
 
diff -Nru a/include/asm-alpha/kmap_types.h b/include/asm-alpha/kmap_types.h
--- a/include/asm-alpha/kmap_types.h	Thu Oct 23 10:54:38 2003
+++ /dev/null	Wed Dec 31 16:00:00 1969
@@ -1,33 +0,0 @@
-#ifndef _ASM_KMAP_TYPES_H
-#define _ASM_KMAP_TYPES_H
-
-/* Dummy header just to define km_type. */
-
-#include <linux/config.h>
-
-#ifdef CONFIG_DEBUG_HIGHMEM
-# define D(n) __KM_FENCE_##n ,
-#else
-# define D(n)
-#endif
-
-enum km_type {
-D(0)	KM_BOUNCE_READ,
-D(1)	KM_SKB_SUNRPC_DATA,
-D(2)	KM_SKB_DATA_SOFTIRQ,
-D(3)	KM_USER0,
-D(4)	KM_USER1,
-D(5)	KM_BIO_SRC_IRQ,
-D(6)	KM_BIO_DST_IRQ,
-D(7)	KM_PTE0,
-D(8)	KM_PTE1,
-D(9)	KM_IRQ0,
-D(10)	KM_IRQ1,
-D(11)	KM_SOFTIRQ0,
-D(12)	KM_SOFTIRQ1,
-D(13)	KM_TYPE_NR
-};
-
-#undef D
-
-#endif
diff -Nru a/include/asm-arm/kmap_types.h b/include/asm-arm/kmap_types.h
--- a/include/asm-arm/kmap_types.h	Thu Oct 23 10:54:38 2003
+++ /dev/null	Wed Dec 31 16:00:00 1969
@@ -1,12 +0,0 @@
-#ifndef __ARM_KMAP_TYPES_H
-#define __ARM_KMAP_TYPES_H
-
-/*
- * This is the "bare minimum".  AIO seems to require this.
- */
-enum km_type {
-	KM_IRQ0,
-	KM_USER1
-};
-
-#endif
diff -Nru a/include/asm-arm26/kmap_types.h b/include/asm-arm26/kmap_types.h
--- a/include/asm-arm26/kmap_types.h	Thu Oct 23 10:54:38 2003
+++ /dev/null	Wed Dec 31 16:00:00 1969
@@ -1,12 +0,0 @@
-#ifndef __ARM_KMAP_TYPES_H
-#define __ARM_KMAP_TYPES_H
-
-/*
- * This is the "bare minimum".  AIO seems to require this.
- */
-enum km_type {
-        KM_IRQ0,
-        KM_USER1
-};
-
-#endif
diff -Nru a/include/asm-cris/kmap_types.h b/include/asm-cris/kmap_types.h
--- a/include/asm-cris/kmap_types.h	Thu Oct 23 10:54:38 2003
+++ /dev/null	Wed Dec 31 16:00:00 1969
@@ -1,25 +0,0 @@
-#ifndef _ASM_KMAP_TYPES_H
-#define _ASM_KMAP_TYPES_H
-
-/* Dummy header just to define km_type.  None of this
- * is actually used on cris. 
- */
-
-enum km_type {
-	KM_BOUNCE_READ,
-	KM_SKB_SUNRPC_DATA,
-	KM_SKB_DATA_SOFTIRQ,
-	KM_USER0,
-	KM_USER1,
-	KM_BIO_SRC_IRQ,
-	KM_BIO_DST_IRQ,
-	KM_PTE0,
-	KM_PTE1,
-	KM_IRQ0,
-	KM_IRQ1,
-	KM_CRYPTO_USER,
-	KM_CRYPTO_SOFTIRQ,
-	KM_TYPE_NR
-};
-
-#endif
diff -Nru a/include/asm-h8300/kmap_types.h b/include/asm-h8300/kmap_types.h
--- a/include/asm-h8300/kmap_types.h	Thu Oct 23 10:54:38 2003
+++ /dev/null	Wed Dec 31 16:00:00 1969
@@ -1,19 +0,0 @@
-#ifndef _ASM_KMAP_TYPES_H
-#define _ASM_KMAP_TYPES_H
-
-enum km_type {
-	KM_BOUNCE_READ,
-	KM_SKB_SUNRPC_DATA,
-	KM_SKB_DATA_SOFTIRQ,
-	KM_USER0,
-	KM_USER1,
-	KM_BIO_SRC_IRQ,
-	KM_BIO_DST_IRQ,
-	KM_PTE0,
-	KM_PTE1,
-	KM_IRQ0,
-	KM_IRQ1,
-	KM_TYPE_NR
-};
-
-#endif
diff -Nru a/include/asm-ia64/kmap_types.h b/include/asm-ia64/kmap_types.h
--- a/include/asm-ia64/kmap_types.h	Thu Oct 23 10:54:38 2003
+++ /dev/null	Wed Dec 31 16:00:00 1969
@@ -1,31 +0,0 @@
-#ifndef _ASM_IA64_KMAP_TYPES_H
-#define _ASM_IA64_KMAP_TYPES_H
-
-#include <linux/config.h>
-
-#ifdef CONFIG_DEBUG_HIGHMEM
-# define D(n) __KM_FENCE_##n ,
-#else
-# define D(n)
-#endif
-
-enum km_type {
-D(0)	KM_BOUNCE_READ,
-D(1)	KM_SKB_SUNRPC_DATA,
-D(2)	KM_SKB_DATA_SOFTIRQ,
-D(3)	KM_USER0,
-D(4)	KM_USER1,
-D(5)	KM_BIO_SRC_IRQ,
-D(6)	KM_BIO_DST_IRQ,
-D(7)	KM_PTE0,
-D(8)	KM_PTE1,
-D(9)	KM_IRQ0,
-D(10)	KM_IRQ1,
-D(11)	KM_SOFTIRQ0,
-D(12)	KM_SOFTIRQ1,
-D(13)	KM_TYPE_NR
-};
-
-#undef D
-
-#endif /* _ASM_IA64_KMAP_TYPES_H */
diff -Nru a/include/asm-m68k/kmap_types.h b/include/asm-m68k/kmap_types.h
--- a/include/asm-m68k/kmap_types.h	Thu Oct 23 10:54:38 2003
+++ /dev/null	Wed Dec 31 16:00:00 1969
@@ -1,21 +0,0 @@
-#ifndef __ASM_M68K_KMAP_TYPES_H
-#define __ASM_M68K_KMAP_TYPES_H
-
-enum km_type {
-	KM_BOUNCE_READ,
-	KM_SKB_SUNRPC_DATA,
-	KM_SKB_DATA_SOFTIRQ,
-	KM_USER0,
-	KM_USER1,
-	KM_BIO_SRC_IRQ,
-	KM_BIO_DST_IRQ,
-	KM_PTE0,
-	KM_PTE1,
-	KM_IRQ0,
-	KM_IRQ1,
-	KM_SOFTIRQ0,
-	KM_SOFTIRQ1,
-	KM_TYPE_NR
-};
-
-#endif	/* __ASM_M68K_KMAP_TYPES_H */
diff -Nru a/include/asm-m68knommu/kmap_types.h b/include/asm-m68knommu/kmap_types.h
--- a/include/asm-m68knommu/kmap_types.h	Thu Oct 23 10:54:38 2003
+++ /dev/null	Wed Dec 31 16:00:00 1969
@@ -1,19 +0,0 @@
-#ifndef _ASM_KMAP_TYPES_H
-#define _ASM_KMAP_TYPES_H
-
-enum km_type {
-	KM_BOUNCE_READ,
-	KM_SKB_SUNRPC_DATA,
-	KM_SKB_DATA_SOFTIRQ,
-	KM_USER0,
-	KM_USER1,
-	KM_BIO_SRC_IRQ,
-	KM_BIO_DST_IRQ,
-	KM_PTE0,
-	KM_PTE1,
-	KM_IRQ0,
-	KM_IRQ1,
-	KM_TYPE_NR
-};
-
-#endif
diff -Nru a/include/asm-parisc/kmap_types.h b/include/asm-parisc/kmap_types.h
--- a/include/asm-parisc/kmap_types.h	Thu Oct 23 10:54:38 2003
+++ /dev/null	Wed Dec 31 16:00:00 1969
@@ -1,31 +0,0 @@
-#ifndef _ASM_KMAP_TYPES_H
-#define _ASM_KMAP_TYPES_H
-
-#include <linux/config.h>
-
-#ifdef CONFIG_DEBUG_HIGHMEM
-# define D(n) __KM_FENCE_##n ,
-#else
-# define D(n)
-#endif
-
-enum km_type {
-D(0)	KM_BOUNCE_READ,
-D(1)	KM_SKB_SUNRPC_DATA,
-D(2)	KM_SKB_DATA_SOFTIRQ,
-D(3)	KM_USER0,
-D(4)	KM_USER1,
-D(5)	KM_BIO_SRC_IRQ,
-D(6)	KM_BIO_DST_IRQ,
-D(7)	KM_PTE0,
-D(8)	KM_PTE1,
-D(9)	KM_IRQ0,
-D(10)	KM_IRQ1,
-D(11)	KM_SOFTIRQ0,
-D(12)	KM_SOFTIRQ1,
-D(13)	KM_TYPE_NR
-};
-
-#undef D
-
-#endif
diff -Nru a/include/asm-ppc64/kmap_types.h b/include/asm-ppc64/kmap_types.h
--- a/include/asm-ppc64/kmap_types.h	Thu Oct 23 10:54:38 2003
+++ /dev/null	Wed Dec 31 16:00:00 1969
@@ -1,23 +0,0 @@
-#ifdef __KERNEL__
-#ifndef _ASM_KMAP_TYPES_H
-#define _ASM_KMAP_TYPES_H
-
-enum km_type {
-	KM_BOUNCE_READ,
-	KM_SKB_SUNRPC_DATA,
-	KM_SKB_DATA_SOFTIRQ,
-	KM_USER0,
-	KM_USER1,
-	KM_BIO_SRC_IRQ,
-	KM_BIO_DST_IRQ,
-	KM_PTE0,
-	KM_PTE1,
-	KM_IRQ0,
-	KM_IRQ1,
-	KM_SOFTIRQ0,
-	KM_SOFTIRQ1,	
-	KM_TYPE_NR
-};
-
-#endif
-#endif /* __KERNEL__ */
diff -Nru a/include/asm-s390/kmap_types.h b/include/asm-s390/kmap_types.h
--- a/include/asm-s390/kmap_types.h	Thu Oct 23 10:54:38 2003
+++ /dev/null	Wed Dec 31 16:00:00 1969
@@ -1,23 +0,0 @@
-#ifdef __KERNEL__
-#ifndef _ASM_KMAP_TYPES_H
-#define _ASM_KMAP_TYPES_H
-
-enum km_type {
-	KM_BOUNCE_READ,
-	KM_SKB_SUNRPC_DATA,
-	KM_SKB_DATA_SOFTIRQ,
-	KM_USER0,
-	KM_USER1,
-	KM_BIO_SRC_IRQ,
-	KM_BIO_DST_IRQ,
-	KM_PTE0,
-	KM_PTE1,
-	KM_IRQ0,
-	KM_IRQ1,
-	KM_SOFTIRQ0,
-	KM_SOFTIRQ1,	
-	KM_TYPE_NR
-};
-
-#endif
-#endif /* __KERNEL__ */
diff -Nru a/include/asm-sh/kmap_types.h b/include/asm-sh/kmap_types.h
--- a/include/asm-sh/kmap_types.h	Thu Oct 23 10:54:38 2003
+++ /dev/null	Wed Dec 31 16:00:00 1969
@@ -1,33 +0,0 @@
-#ifndef __SH_KMAP_TYPES_H
-#define __SH_KMAP_TYPES_H
-
-/* Dummy header just to define km_type. */
-
-#include <linux/config.h>
-
-#if CONFIG_DEBUG_HIGHMEM
-# define D(n) __KM_FENCE_##n ,
-#else
-# define D(n)
-#endif
-
-enum km_type {
-D(0)	KM_BOUNCE_READ,
-D(1)	KM_SKB_SUNRPC_DATA,
-D(2)	KM_SKB_DATA_SOFTIRQ,
-D(3)	KM_USER0,
-D(4)	KM_USER1,
-D(5)	KM_BIO_SRC_IRQ,
-D(6)	KM_BIO_DST_IRQ,
-D(7)	KM_PTE0,
-D(8)	KM_PTE1,
-D(9)	KM_IRQ0,
-D(10)	KM_IRQ1,
-D(11)	KM_SOFTIRQ0,
-D(12)	KM_SOFTIRQ1,
-D(13)	KM_TYPE_NR
-};
-
-#undef D
-
-#endif
diff -Nru a/include/asm-sparc64/kmap_types.h b/include/asm-sparc64/kmap_types.h
--- a/include/asm-sparc64/kmap_types.h	Thu Oct 23 10:54:38 2003
+++ /dev/null	Wed Dec 31 16:00:00 1969
@@ -1,25 +0,0 @@
-#ifndef _ASM_KMAP_TYPES_H
-#define _ASM_KMAP_TYPES_H
-
-/* Dummy header just to define km_type.  None of this
- * is actually used on sparc64.  -DaveM
- */
-
-enum km_type {
-	KM_BOUNCE_READ,
-	KM_SKB_SUNRPC_DATA,
-	KM_SKB_DATA_SOFTIRQ,
-	KM_USER0,
-	KM_USER1,
-	KM_BIO_SRC_IRQ,
-	KM_BIO_DST_IRQ,
-	KM_PTE0,
-	KM_PTE1,
-	KM_IRQ0,
-	KM_IRQ1,
-	KM_SOFTIRQ0,
-	KM_SOFTIRQ1,
-	KM_TYPE_NR
-};
-
-#endif
diff -Nru a/include/asm-v850/kmap_types.h b/include/asm-v850/kmap_types.h
--- a/include/asm-v850/kmap_types.h	Thu Oct 23 10:54:38 2003
+++ /dev/null	Wed Dec 31 16:00:00 1969
@@ -1,19 +0,0 @@
-#ifndef __V850_KMAP_TYPES_H__
-#define __V850_KMAP_TYPES_H__
-
-enum km_type {
-	KM_BOUNCE_READ,
-	KM_SKB_SUNRPC_DATA,
-	KM_SKB_DATA_SOFTIRQ,
-	KM_USER0,
-	KM_USER1,
-	KM_BIO_SRC_IRQ,
-	KM_BIO_DST_IRQ,
-	KM_PTE0,
-	KM_PTE1,
-	KM_IRQ0,
-	KM_IRQ1,
-	KM_TYPE_NR
-};
-
-#endif /* __V850_KMAP_TYPES_H__ */
diff -Nru a/include/asm-x86_64/kmap_types.h b/include/asm-x86_64/kmap_types.h
--- a/include/asm-x86_64/kmap_types.h	Thu Oct 23 10:54:38 2003
+++ /dev/null	Wed Dec 31 16:00:00 1969
@@ -1,19 +0,0 @@
-#ifndef _ASM_KMAP_TYPES_H
-#define _ASM_KMAP_TYPES_H
-
-enum km_type {
-	KM_BOUNCE_READ,
-	KM_SKB_SUNRPC_DATA,
-	KM_SKB_DATA_SOFTIRQ,
-	KM_USER0,
-	KM_USER1,
-	KM_BIO_SRC_IRQ,
-	KM_BIO_DST_IRQ,
-	KM_IRQ0,
-	KM_IRQ1,
-	KM_SOFTIRQ0,
-	KM_SOFTIRQ1,
-	KM_TYPE_NR
-};
-
-#endif
diff -Nru a/include/linux/highmem.h b/include/linux/highmem.h
--- a/include/linux/highmem.h	Thu Oct 23 10:54:38 2003
+++ b/include/linux/highmem.h	Thu Oct 23 10:54:38 2003
@@ -12,6 +12,7 @@
 extern struct page *highmem_start_page;
 
 #include <asm/highmem.h>
+#include <asm/kmap_types.h>
 
 /* declarations for linux/mm/highmem.c */
 unsigned int nr_free_highpages(void);
@@ -25,6 +26,16 @@
 	might_sleep();
 	return page_address(page);
 }
+
+/* generic code may use these, even when CONFIG_HIGHMEM is not set */
+enum km_type {
+	KM_USER0,
+	KM_USER1,
+	KM_IRQ0,
+	KM_IRQ1,
+	KM_SOFTIRQ0,
+	KM_SOFTIRQ1,
+};
 
 #define kunmap(page) do { (void) (page); } while (0)
 

