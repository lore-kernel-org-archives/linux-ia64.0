From: Zou Nan hai <nanhai.zou@intel.com>
Date: Fri, 14 Apr 2006 00:52:33 +0000
Subject: Re: [PATCH 6/8] IA64 various hugepage size - introduce prctl
Message-Id: <1144975953.5817.102.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
References: <1144974367.5817.39.camel@linux-znh>
	 <1144974667.5817.51.camel@linux-znh>  <1144974881.5817.59.camel@linux-znh>
	 <1144975292.5817.74.camel@linux-znh>  <1144975523.5817.84.camel@linux-znh>
	 <1144975746.5817.94.camel@linux-znh>
In-Reply-To: <1144975746.5817.94.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>
Cc: Linux-IA64 <linux-ia64@vger.kernel.org>, Tony <tony.luck@intel.com>, Kenneth W <kenneth.w.chen@intel.com>

Introduce 2 prctl option to set/get hugepage size.


Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>

diff -Nraup a/arch/ia64/mm/hugetlbpage.c b/arch/ia64/mm/hugetlbpage.c
--- a/arch/ia64/mm/hugetlbpage.c	2006-04-13 08:41:37.000000000 +0800
+++ b/arch/ia64/mm/hugetlbpage.c	2006-04-13 08:34:57.000000000 +0800
@@ -194,3 +194,25 @@ int is_valid_hpage_size(unsigned long lo
         return 1;
 }
 
+int set_hugepagesize(struct task_struct *task,unsigned long size)
+{
+	struct mm_struct *mm = task->mm;
+	struct vm_area_struct *vma;
+	unsigned int shift;
+	if (!is_valid_hpage_size(size))
+		return -EINVAL;
+	shift = __ffs(size);
+	if (shift = mm->hugepage_shift)
+		return 0;
+	down_write(&mm->mmap_sem);
+	for (vma = mm->mmap; vma ; vma = vma->vm_next) {
+		if (vma->vm_flags & VM_HUGETLB) {
+			up_write(&mm->mmap_sem);
+			return -EPERM;
+		}
+	}
+	mm->hugepage_shift = shift;
+	activate_mm(mm, mm);
+	up_write(&mm->mmap_sem);
+	return 0;
+}
diff -Nraup a/include/asm-ia64/page.h b/include/asm-ia64/page.h
--- a/include/asm-ia64/page.h	2006-04-13 08:41:37.000000000 +0800
+++ b/include/asm-ia64/page.h	2006-04-13 08:30:21.000000000 +0800
@@ -166,6 +166,8 @@ typedef union ia64_va {
 	 (REGION_NUMBER(addr) = RGN_HPAGE ||	\
 	  REGION_NUMBER((addr)+(len)-1) = RGN_HPAGE)
 extern unsigned int init_hpage_shift;
+struct task_struct;
+extern int set_hugepagesize(struct task_struct *,unsigned long);
 #endif
 
 static __inline__ int
diff -Nraup a/include/asm-ia64/processor.h b/include/asm-ia64/processor.h
--- a/include/asm-ia64/processor.h	2006-04-13 08:41:37.000000000 +0800
+++ b/include/asm-ia64/processor.h	2006-04-13 08:30:13.000000000 +0800
@@ -211,6 +211,14 @@ typedef struct {
 		 (int __user *) (addr));							\
 })
 
+#ifdef CONFIG_HUGETLB_PAGE
+#define	GET_HUGEPAGESIZE(task,addr) \
+({	put_user((1UL<<(task)->mm->hugepage_shift), \
+		(unsigned long __user *)(addr)); \
+})
+#define SET_HUGEPAGESIZE(task,size) set_hugepagesize(task,size)
+#endif
+
 #ifdef CONFIG_IA32_SUPPORT
 struct desc_struct {
 	unsigned int a, b;
diff -Nraup a/include/linux/prctl.h b/include/linux/prctl.h
--- a/include/linux/prctl.h	2006-03-20 13:53:29.000000000 +0800
+++ b/include/linux/prctl.h	2006-04-13 08:43:37.000000000 +0800
@@ -52,4 +52,8 @@
 #define PR_SET_NAME    15		/* Set process name */
 #define PR_GET_NAME    16		/* Get process name */
 
+/* Get/set task huge page size (if meaningful) */
+#define PR_SET_HUGEPAGE_SIZE	17
+#define PR_GET_HUGEPAGE_SIZE	18
+
 #endif /* _LINUX_PRCTL_H */
diff -Nraup a/kernel/sys.c b/kernel/sys.c
--- a/kernel/sys.c	2006-04-13 08:41:37.000000000 +0800
+++ b/kernel/sys.c	2006-04-13 08:47:41.000000000 +0800
@@ -57,6 +57,12 @@
 #ifndef GET_FPEXC_CTL
 # define GET_FPEXC_CTL(a,b)	(-EINVAL)
 #endif
+#ifndef GET_HUGEPAGESIZE
+# define GET_HUGEPAGESIZE(a,b)  (-EINVAL)
+#endif
+#ifndef SET_HUGEPAGESIZE
+# define SET_HUGEPAGESIZE(a,b)  (-EINVAL)
+#endif
 
 /*
  * this is where the system-wide overflow UID and GID are defined, for
@@ -2057,6 +2063,12 @@ asmlinkage long sys_prctl(int option, un
 				return -EFAULT;
 			return 0;
 		}
+		case PR_SET_HUGEPAGE_SIZE:
+			error = SET_HUGEPAGESIZE(current, arg2);
+			break;
+		case PR_GET_HUGEPAGE_SIZE:
+			error = GET_HUGEPAGESIZE(current, arg2);
+			break;
 		default:
 			error = -EINVAL;
 			break;

