From: Martin Hicks <mort@sgi.com>
Date: Fri, 06 Feb 2004 18:31:05 +0000
Subject: Re: linux-2.5 tree no longer builds.
Message-Id: <20040206183105.GD21486@localhost>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="V0207lvV8h4k8FAm"
List-Id: <linux-ia64.vger.kernel.org>
References: <20040206172007.GA19538@lnx-holt>
In-Reply-To: <20040206172007.GA19538@lnx-holt>
To: linux-ia64@vger.kernel.org


--V0207lvV8h4k8FAm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


Robin,

The fix is attached.  It's already on its way into linux-2.5 through
Andrew Morton.

mh


On Fri, Feb 06, 2004 at 11:20:07AM -0600, Robin Holt wrote:
> It appears that the following:
> 
> ChangeSet 1.1532.9.160 2004/02/04 10:54:15 akpm@osdl.org
>   [PATCH] Fix ptrace in the vsyscall dso area
>   
>   From: Roland McGrath <roland@redhat.com>
>   
>   The #include is the part of this patch that matters, so the #ifdef below
>   works.
> 
> breaks the linux.bkbits.net/linux-2.5 tree for ia64 with the following:
> 
> arch/ia64/ia32/elfcore32.h:20: conflicting types for `elf_gregset_t'
> include/asm/elf.h:160: previous declaration of `elf_gregset_t'
> arch/ia64/ia32/elfcore32.h:22: conflicting types for `elf_fpregset_t'
> include/asm/elf.h:163: previous declaration of `elf_fpregset_t'
> arch/ia64/ia32/elfcore32.h:23: conflicting types for `elf_fpxregset_t'
> include/asm/elf.h:157: previous declaration of `elf_fpxregset_t'
> In file included from arch/ia64/ia32/binfmt_elf32.c:22:
> arch/ia64/ia32/elfcore32.h:69:1: warning: "ELF_CORE_COPY_REGS" redefined
> In file included from include/linux/elf.h:5,
>                  from include/linux/mm.h:15,
>                  from arch/ia64/ia32/binfmt_elf32.c:15:
> include/asm/elf.h:169:1: warning: this is the location of the previous definition
> 
> 
> 
> I commented out the #include in linux/mm.h and everything builds fine.
> I haven't booted it yet.
> 
> Does anybody have a correct fix?
> 
> Thanks,
> Robin Holt
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Martin Hicks || mort@bork.org || PGP/GnuPG: 0x4C7F2BEE

--V0207lvV8h4k8FAm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="elf-fix.patch"


The hunk that includes elf.h into include/linux/mm.h breaks the build on
 ia64.  2.6.2-mm1

Thanks for testing it.  Does the below fix it?

Begin forwarded message:

Date: Thu, 5 Feb 2004 18:01:21 +0100
From: Andi Kleen <ak@suse.de>
To: Andi Kleen <ak@suse.de>
Cc: akpm@osdl.org, torvalds@osdl.org, discuss@x86-64.org
Subject: Re: [PATCH] Fix x86-64 compilation on 2.6.2-bk1 - new patch


On Thu, 5 Feb 2004 17:07:14 +0100
Andi Kleen <ak@suse.de> wrote:

> 
> The new linux/elf.h include in linux/mm.h caused all kinds of problems for the x86-64
> 32bit emulation code. 
> 
> This patch avoids the dependency by moving the depending functions out of 
> line. It makes x86-64 compile again.
> 
> Please apply.

[...] 

Unfortunately that patch broke the build on some other architectures (e.g. s390) due 
to a wrong ifdef.

Here is the corrected version: 

diff -u linux-2.6.2bk1/include/linux/mm.h-o linux-2.6.2bk1/include/linux/mm.h
--- linux-2.6.2bk1/include/linux/mm.h-o	2004-02-05 17:48:27.000000000 +0100
+++ linux-2.6.2bk1/include/linux/mm.h	2004-02-05 17:53:44.295452824 +0100
@@ -12,7 +12,6 @@
 #include <linux/mmzone.h>
 #include <linux/rbtree.h>
 #include <linux/fs.h>
-#include <linux/elf.h>
 
 #ifndef CONFIG_DISCONTIGMEM          /* Don't use mapnrs, do it properly */
 extern unsigned long max_mapnr;
@@ -644,24 +643,8 @@
 #endif
 
 #ifndef CONFIG_ARCH_GATE_AREA
-static inline int in_gate_area(struct task_struct *task, unsigned long addr)
-{
-#ifdef AT_SYSINFO_EHDR
-	if ((addr >= FIXADDR_USER_START) && (addr < FIXADDR_USER_END))
-		return 1;
-#endif
-	return 0;
-}
-
-extern struct vm_area_struct gate_vma;
-static inline struct vm_area_struct *get_gate_vma(struct task_struct *tsk)
-{
-#ifdef AT_SYSINFO_EHDR
-	return &gate_vma;
-#else
-	return 0;
-#endif
-}
+extern struct vm_area_struct *get_gate_vma(struct task_struct *tsk);
+int in_gate_area(struct task_struct *task, unsigned long addr);
 #endif
 
 #endif /* __KERNEL__ */
diff -u linux-2.6.2bk1/mm/memory.c-o linux-2.6.2bk1/mm/memory.c
--- linux-2.6.2bk1/mm/memory.c-o	2004-02-05 12:23:20.000000000 +0100
+++ linux-2.6.2bk1/mm/memory.c	2004-02-05 17:59:58.308594184 +0100
@@ -55,6 +55,7 @@
 #include <asm/pgtable.h>
 
 #include <linux/swapops.h>
+#include <linux/elf.h>
 
 #ifndef CONFIG_DISCONTIGMEM
 /* use the per-pgdat data instead for discontigmem - mbligh */
@@ -1688,7 +1689,9 @@
 
 EXPORT_SYMBOL(vmalloc_to_page);
 
-#if !defined(CONFIG_ARCH_GATE_AREA) && defined(AT_SYSINFO_EHDR)
+#if !defined(CONFIG_ARCH_GATE_AREA)
+
+#if defined(AT_SYSINFO_EHDR)
 struct vm_area_struct gate_vma;
 
 static int __init gate_vma_init(void)
@@ -1702,3 +1705,23 @@
 }
 __initcall(gate_vma_init);
 #endif
+
+struct vm_area_struct *get_gate_vma(struct task_struct *tsk)
+{
+#ifdef AT_SYSINFO_EHDR
+	return &gate_vma;
+#else
+	return 0;
+#endif
+}
+
+int in_gate_area(struct task_struct *task, unsigned long addr)
+{
+#ifdef AT_SYSINFO_EHDR
+	if ((addr >= FIXADDR_USER_START) && (addr < FIXADDR_USER_END))
+		return 1;
+#endif
+	return 0;
+}
+
+#endif

--V0207lvV8h4k8FAm--
