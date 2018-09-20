From: Alexandre Ghiti <alex@ghiti.fr>
Date: Thu, 20 Sep 2018 06:03:51 +0000
Subject: [PATCH v7 04/11] hugetlb: Introduce generic version of huge_ptep_get_and_clear
Message-Id: <20180920060358.16606-5-alex@ghiti.fr>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180920060358.16606-1-alex@ghiti.fr>
In-Reply-To: <20180920060358.16606-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org
Cc: linux-mips@linux-mips.org, dalias@libc.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, benh@kernel.crashing.org, will.deacon@arm.com, jejb@parisc-linux.org, linux-mm@kvack.org, paulus@samba.org, hpa@zytor.com, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, ysato@users.sourceforge.jp, mpe@ellerman.id.au, deller@gmx.de, x86@kernel.org, linux@armlinux.org.uk, mingo@redhat.com, catalin.marinas@arm.com, jhogan@kernel.org, fenghua.yu@intel.com, arnd@arndb.de, tglx@linutronix.de, linux-arm-kernel@lists.infradead.org, tony.luck@intel.com, Alexandre Ghiti <alex@ghiti.fr>, linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org, ralf@linux-mips.org, paul.burton@mips.com, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net, mike.kravetz@oracle.com

arm, ia64, sh, x86 architectures use the
same version of huge_ptep_get_and_clear, so move this generic
implementation into asm-generic/hugetlb.h.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Tested-by: Helge Deller <deller@gmx.de> # parisc
Acked-by: Catalin Marinas <catalin.marinas@arm.com> # arm64
Acked-by: Paul Burton <paul.burton@mips.com> # MIPS parts
Acked-by: Ingo Molnar <mingo@kernel.org> # x86
Reviewed-by: Luiz Capitulino <lcapitulino@redhat.com>
Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 arch/arm/include/asm/hugetlb-3level.h | 6 ------
 arch/arm64/include/asm/hugetlb.h      | 1 +
 arch/ia64/include/asm/hugetlb.h       | 6 ------
 arch/mips/include/asm/hugetlb.h       | 1 +
 arch/parisc/include/asm/hugetlb.h     | 1 +
 arch/powerpc/include/asm/hugetlb.h    | 1 +
 arch/sh/include/asm/hugetlb.h         | 6 ------
 arch/sparc/include/asm/hugetlb.h      | 1 +
 arch/x86/include/asm/hugetlb.h        | 6 ------
 include/asm-generic/hugetlb.h         | 8 ++++++++
 10 files changed, 13 insertions(+), 24 deletions(-)

diff --git a/arch/arm/include/asm/hugetlb-3level.h b/arch/arm/include/asm/hugetlb-3level.h
index 398fb06e8207..ad36e84b819a 100644
--- a/arch/arm/include/asm/hugetlb-3level.h
+++ b/arch/arm/include/asm/hugetlb-3level.h
@@ -49,12 +49,6 @@ static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
 	ptep_set_wrprotect(mm, addr, ptep);
 }
 
-static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
-					    unsigned long addr, pte_t *ptep)
-{
-	return ptep_get_and_clear(mm, addr, ptep);
-}
-
 static inline int huge_ptep_set_access_flags(struct vm_area_struct *vma,
 					     unsigned long addr, pte_t *ptep,
 					     pte_t pte, int dirty)
diff --git a/arch/arm64/include/asm/hugetlb.h b/arch/arm64/include/asm/hugetlb.h
index 874661a1dff1..6ae0bcafe162 100644
--- a/arch/arm64/include/asm/hugetlb.h
+++ b/arch/arm64/include/asm/hugetlb.h
@@ -66,6 +66,7 @@ extern void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 extern int huge_ptep_set_access_flags(struct vm_area_struct *vma,
 				      unsigned long addr, pte_t *ptep,
 				      pte_t pte, int dirty);
+#define __HAVE_ARCH_HUGE_PTEP_GET_AND_CLEAR
 extern pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
 				     unsigned long addr, pte_t *ptep);
 extern void huge_ptep_set_wrprotect(struct mm_struct *mm,
diff --git a/arch/ia64/include/asm/hugetlb.h b/arch/ia64/include/asm/hugetlb.h
index a235d6f60fb3..6719c74da0de 100644
--- a/arch/ia64/include/asm/hugetlb.h
+++ b/arch/ia64/include/asm/hugetlb.h
@@ -20,12 +20,6 @@ static inline int is_hugepage_only_range(struct mm_struct *mm,
 		REGION_NUMBER((addr)+(len)-1) = RGN_HPAGE);
 }
 
-static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
-					    unsigned long addr, pte_t *ptep)
-{
-	return ptep_get_and_clear(mm, addr, ptep);
-}
-
 static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
 					 unsigned long addr, pte_t *ptep)
 {
diff --git a/arch/mips/include/asm/hugetlb.h b/arch/mips/include/asm/hugetlb.h
index 8ea439041d5d..0959cc5a41fa 100644
--- a/arch/mips/include/asm/hugetlb.h
+++ b/arch/mips/include/asm/hugetlb.h
@@ -36,6 +36,7 @@ static inline int prepare_hugepage_range(struct file *file,
 	return 0;
 }
 
+#define __HAVE_ARCH_HUGE_PTEP_GET_AND_CLEAR
 static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
 					    unsigned long addr, pte_t *ptep)
 {
diff --git a/arch/parisc/include/asm/hugetlb.h b/arch/parisc/include/asm/hugetlb.h
index 77c8adbac7c3..6e281e1bb336 100644
--- a/arch/parisc/include/asm/hugetlb.h
+++ b/arch/parisc/include/asm/hugetlb.h
@@ -8,6 +8,7 @@
 void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 		     pte_t *ptep, pte_t pte);
 
+#define __HAVE_ARCH_HUGE_PTEP_GET_AND_CLEAR
 pte_t huge_ptep_get_and_clear(struct mm_struct *mm, unsigned long addr,
 			      pte_t *ptep);
 
diff --git a/arch/powerpc/include/asm/hugetlb.h b/arch/powerpc/include/asm/hugetlb.h
index 33b899624922..91bdc84b76ce 100644
--- a/arch/powerpc/include/asm/hugetlb.h
+++ b/arch/powerpc/include/asm/hugetlb.h
@@ -129,6 +129,7 @@ static inline int prepare_hugepage_range(struct file *file,
 	return 0;
 }
 
+#define __HAVE_ARCH_HUGE_PTEP_GET_AND_CLEAR
 static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
 					    unsigned long addr, pte_t *ptep)
 {
diff --git a/arch/sh/include/asm/hugetlb.h b/arch/sh/include/asm/hugetlb.h
index bc552e37c1c9..08ee6c00b5e9 100644
--- a/arch/sh/include/asm/hugetlb.h
+++ b/arch/sh/include/asm/hugetlb.h
@@ -25,12 +25,6 @@ static inline int prepare_hugepage_range(struct file *file,
 	return 0;
 }
 
-static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
-					    unsigned long addr, pte_t *ptep)
-{
-	return ptep_get_and_clear(mm, addr, ptep);
-}
-
 static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
 					 unsigned long addr, pte_t *ptep)
 {
diff --git a/arch/sparc/include/asm/hugetlb.h b/arch/sparc/include/asm/hugetlb.h
index 16b0c53ea6c9..944e3a4bfaff 100644
--- a/arch/sparc/include/asm/hugetlb.h
+++ b/arch/sparc/include/asm/hugetlb.h
@@ -16,6 +16,7 @@ extern struct pud_huge_patch_entry __pud_huge_patch, __pud_huge_patch_end;
 void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 		     pte_t *ptep, pte_t pte);
 
+#define __HAVE_ARCH_HUGE_PTEP_GET_AND_CLEAR
 pte_t huge_ptep_get_and_clear(struct mm_struct *mm, unsigned long addr,
 			      pte_t *ptep);
 
diff --git a/arch/x86/include/asm/hugetlb.h b/arch/x86/include/asm/hugetlb.h
index 8db9a761964d..e9e7fef867ad 100644
--- a/arch/x86/include/asm/hugetlb.h
+++ b/arch/x86/include/asm/hugetlb.h
@@ -28,12 +28,6 @@ static inline int prepare_hugepage_range(struct file *file,
 	return 0;
 }
 
-static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
-					    unsigned long addr, pte_t *ptep)
-{
-	return ptep_get_and_clear(mm, addr, ptep);
-}
-
 static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
 					 unsigned long addr, pte_t *ptep)
 {
diff --git a/include/asm-generic/hugetlb.h b/include/asm-generic/hugetlb.h
index ee010b756246..0f6f151780dd 100644
--- a/include/asm-generic/hugetlb.h
+++ b/include/asm-generic/hugetlb.h
@@ -57,4 +57,12 @@ static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 }
 #endif
 
+#ifndef __HAVE_ARCH_HUGE_PTEP_GET_AND_CLEAR
+static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
+		unsigned long addr, pte_t *ptep)
+{
+	return ptep_get_and_clear(mm, addr, ptep);
+}
+#endif
+
 #endif /* _ASM_GENERIC_HUGETLB_H */
-- 
2.16.2
