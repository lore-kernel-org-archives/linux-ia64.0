From: Mike Rapoport <rppt@kernel.org>
Date: Sun, 12 Feb 2023 08:46:10 +0000
Subject: [PATCH 1/2] char/agp: consolidate {alloc,free}_gatt_pages()
Message-Id: <20230212084611.1311177-2-rppt@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230212084611.1311177-1-rppt@kernel.org>
In-Reply-To: <20230212084611.1311177-1-rppt@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: David Airlie <airlied@redhat.com>, "David S. Miller" <davem@davemloft.net>, Helge Deller <deller@gmx.de>, Matt Turner <mattst88@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, dri-devel@lists.freedesktop.org, linux-alpha@vger.kernel.org, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, "Mike Rapoport (IBM)" <rppt@kernel.org>

From: "Mike Rapoport (IBM)" <rppt@kernel.org>

There is a copy of alloc_gatt_pages() and free_gatt_pages in several
architectures in arch/$ARCH/include/asm/agp.h. All the copies do exactly
the same: alias alloc_gatt_pages() to __get_free_pages(GFP_KERNEL) and
alias free_gatt_pages() to free_pages().

Define alloc_gatt_pages() and free_gatt_pages() in drivers/char/agp/agp.h
and drop per-architecture definitions.

Signed-off-by: Mike Rapoport (IBM) <rppt@kernel.org>
---
 arch/alpha/include/asm/agp.h   | 6 ------
 arch/ia64/include/asm/agp.h    | 6 ------
 arch/parisc/include/asm/agp.h  | 6 ------
 arch/powerpc/include/asm/agp.h | 6 ------
 arch/sparc/include/asm/agp.h   | 6 ------
 arch/x86/include/asm/agp.h     | 6 ------
 drivers/char/agp/agp.h         | 6 ++++++
 7 files changed, 6 insertions(+), 36 deletions(-)

diff --git a/arch/alpha/include/asm/agp.h b/arch/alpha/include/asm/agp.h
index 7874f063d000..4197b3bc78ee 100644
--- a/arch/alpha/include/asm/agp.h
+++ b/arch/alpha/include/asm/agp.h
@@ -10,10 +10,4 @@
 #define unmap_page_from_agp(page)	do { } while (0)
 #define flush_agp_cache() mb()
 
-/* GATT allocation. Returns/accepts GATT kernel virtual address. */
-#define alloc_gatt_pages(order)		\
-	((char *)__get_free_pages(GFP_KERNEL, (order)))
-#define free_gatt_pages(table, order)	\
-	free_pages((unsigned long)(table), (order))
-
 #endif
diff --git a/arch/ia64/include/asm/agp.h b/arch/ia64/include/asm/agp.h
index 0261507dc264..f42c7dcb3d79 100644
--- a/arch/ia64/include/asm/agp.h
+++ b/arch/ia64/include/asm/agp.h
@@ -18,10 +18,4 @@
 #define unmap_page_from_agp(page)	do { } while (0)
 #define flush_agp_cache()		mb()
 
-/* GATT allocation. Returns/accepts GATT kernel virtual address. */
-#define alloc_gatt_pages(order)		\
-	((char *)__get_free_pages(GFP_KERNEL, (order)))
-#define free_gatt_pages(table, order)	\
-	free_pages((unsigned long)(table), (order))
-
 #endif /* _ASM_IA64_AGP_H */
diff --git a/arch/parisc/include/asm/agp.h b/arch/parisc/include/asm/agp.h
index 14ae54cfd368..d193a48490e2 100644
--- a/arch/parisc/include/asm/agp.h
+++ b/arch/parisc/include/asm/agp.h
@@ -12,10 +12,4 @@
 #define unmap_page_from_agp(page)	do { } while (0)
 #define flush_agp_cache()		mb()
 
-/* GATT allocation. Returns/accepts GATT kernel virtual address. */
-#define alloc_gatt_pages(order)		\
-	((char *)__get_free_pages(GFP_KERNEL, (order)))
-#define free_gatt_pages(table, order)	\
-	free_pages((unsigned long)(table), (order))
-
 #endif /* _ASM_PARISC_AGP_H */
diff --git a/arch/powerpc/include/asm/agp.h b/arch/powerpc/include/asm/agp.h
index 6b6485c988dd..e86f2ce476c9 100644
--- a/arch/powerpc/include/asm/agp.h
+++ b/arch/powerpc/include/asm/agp.h
@@ -9,11 +9,5 @@
 #define unmap_page_from_agp(page) do {} while (0)
 #define flush_agp_cache() mb()
 
-/* GATT allocation. Returns/accepts GATT kernel virtual address. */
-#define alloc_gatt_pages(order)		\
-	((char *)__get_free_pages(GFP_KERNEL, (order)))
-#define free_gatt_pages(table, order)	\
-	free_pages((unsigned long)(table), (order))
-
 #endif /* __KERNEL__ */
 #endif	/* _ASM_POWERPC_AGP_H */
diff --git a/arch/sparc/include/asm/agp.h b/arch/sparc/include/asm/agp.h
index 2d0ff84cee3f..5186924fa673 100644
--- a/arch/sparc/include/asm/agp.h
+++ b/arch/sparc/include/asm/agp.h
@@ -8,10 +8,4 @@
 #define unmap_page_from_agp(page)	do { } while (0)
 #define flush_agp_cache()		mb()
 
-/* GATT allocation. Returns/accepts GATT kernel virtual address. */
-#define alloc_gatt_pages(order)		\
-	((char *)__get_free_pages(GFP_KERNEL, (order)))
-#define free_gatt_pages(table, order)	\
-	free_pages((unsigned long)(table), (order))
-
 #endif
diff --git a/arch/x86/include/asm/agp.h b/arch/x86/include/asm/agp.h
index cd7b14322035..c8c111d8fbd7 100644
--- a/arch/x86/include/asm/agp.h
+++ b/arch/x86/include/asm/agp.h
@@ -23,10 +23,4 @@
  */
 #define flush_agp_cache() wbinvd()
 
-/* GATT allocation. Returns/accepts GATT kernel virtual address. */
-#define alloc_gatt_pages(order)		\
-	((char *)__get_free_pages(GFP_KERNEL, (order)))
-#define free_gatt_pages(table, order)	\
-	free_pages((unsigned long)(table), (order))
-
 #endif /* _ASM_X86_AGP_H */
diff --git a/drivers/char/agp/agp.h b/drivers/char/agp/agp.h
index bb09d64cd51e..8771dcc9b8e2 100644
--- a/drivers/char/agp/agp.h
+++ b/drivers/char/agp/agp.h
@@ -236,6 +236,12 @@ void agp3_generic_tlbflush(struct agp_memory *mem);
 int agp3_generic_configure(void);
 void agp3_generic_cleanup(void);
 
+/* GATT allocation. Returns/accepts GATT kernel virtual address. */
+#define alloc_gatt_pages(order)		\
+	((char *)__get_free_pages(GFP_KERNEL, (order)))
+#define free_gatt_pages(table, order)	\
+	free_pages((unsigned long)(table), (order))
+
 /* aperture sizes have been standardised since v3 */
 #define AGP_GENERIC_SIZES_ENTRIES 11
 extern const struct aper_size_info_16 agp3_generic_sizes[];
-- 
2.35.1
