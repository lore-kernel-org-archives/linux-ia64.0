From: Andy Whitcroft <apw@shadowen.org>
Date: Thu, 25 Mar 2004 16:59:07 +0000
Subject: [PATCH] [2/6] HUGETLB memory commitment
Message-Id: <18703834.1080233947@42.150.104.212.access.eclipse.net.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <18429360.1080233672@42.150.104.212.access.eclipse.net.uk>
In-Reply-To: <18429360.1080233672@42.150.104.212.access.eclipse.net.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Anton Blanchard <anton@samba.org>, Andrew Morton <akpm@osdl.org>, Stephen Smalley <sds@epoch.ncsc.mil>
Cc: Andi Kleen <ak@suse.de>, raybry@sgi.com, lse-tech@lists.sourceforge.net, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, "Martin J. Bligh" <mbligh@aracnet.com>

[055-mem_acctdom_arch]

Memory accounting domains (arch)

---
 ia64/ia32/binfmt_elf32.c  |    3 ++-
 mips/kernel/sysirix.c     |    3 ++-
 s390/kernel/compat_exec.c |    3 ++-
 x86_64/ia32/ia32_binfmt.c |    3 ++-
 4 files changed, 8 insertions(+), 4 deletions(-)

diff -upN reference/arch/ia64/ia32/binfmt_elf32.c current/arch/ia64/ia32/binfmt_elf32.c
--- reference/arch/ia64/ia32/binfmt_elf32.c	2004-03-11 20:47:12.000000000 +0000
+++ current/arch/ia64/ia32/binfmt_elf32.c	2004-03-25 15:03:32.000000000 +0000
@@ -168,7 +168,8 @@ ia32_setup_arg_pages (struct linux_binpr
 	if (!mpnt)
 		return -ENOMEM;
 
-	if (security_vm_enough_memory((IA32_STACK_TOP - (PAGE_MASK & (unsigned long) bprm->p))>>PAGE_SHIFT)) {
+	if (security_vm_enough_memory(VM_AD_DEFAULT, (IA32_STACK_TOP -
+			(PAGE_MASK & (unsigned long) bprm->p))>>PAGE_SHIFT)) {
 		kmem_cache_free(vm_area_cachep, mpnt);
 		return -ENOMEM;
 	}
diff -upN reference/arch/mips/kernel/sysirix.c current/arch/mips/kernel/sysirix.c
--- reference/arch/mips/kernel/sysirix.c	2004-03-11 20:47:13.000000000 +0000
+++ current/arch/mips/kernel/sysirix.c	2004-03-25 15:03:32.000000000 +0000
@@ -578,7 +578,8 @@ asmlinkage int irix_brk(unsigned long br
 	/*
 	 * Check if we have enough memory..
 	 */
-	if (security_vm_enough_memory((newbrk-oldbrk) >> PAGE_SHIFT)) {
+	if (security_vm_enough_memory(VM_AD_DEFAULT,
+			(newbrk-oldbrk) >> PAGE_SHIFT)) {
 		ret = -ENOMEM;
 		goto out;
 	}
diff -upN reference/arch/s390/kernel/compat_exec.c current/arch/s390/kernel/compat_exec.c
--- reference/arch/s390/kernel/compat_exec.c	2004-01-09 06:59:57.000000000 +0000
+++ current/arch/s390/kernel/compat_exec.c	2004-03-25 15:03:32.000000000 +0000
@@ -56,7 +56,8 @@ int setup_arg_pages32(struct linux_binpr
 	if (!mpnt) 
 		return -ENOMEM; 
 	
-	if (security_vm_enough_memory((STACK_TOP - (PAGE_MASK & (unsigned long) bprm->p))>>PAGE_SHIFT)) {
+	if (security_vm_enough_memory(VM_AD_DEFAULT, (STACK_TOP -
+			(PAGE_MASK & (unsigned long) bprm->p))>>PAGE_SHIFT)) {
 		kmem_cache_free(vm_area_cachep, mpnt);
 		return -ENOMEM;
 	}
diff -upN reference/arch/x86_64/ia32/ia32_binfmt.c current/arch/x86_64/ia32/ia32_binfmt.c
--- reference/arch/x86_64/ia32/ia32_binfmt.c	2004-03-25 02:42:14.000000000 +0000
+++ current/arch/x86_64/ia32/ia32_binfmt.c	2004-03-25 15:03:32.000000000 +0000
@@ -344,7 +344,8 @@ int setup_arg_pages(struct linux_binprm 
 	if (!mpnt) 
 		return -ENOMEM; 
 	
-	if (security_vm_enough_memory((IA32_STACK_TOP - (PAGE_MASK & (unsigned long) bprm->p))>>PAGE_SHIFT)) {
+	if (security_vm_enough_memory(VM_AD_DEFAULT, (IA32_STACK_TOP -
+			(PAGE_MASK & (unsigned long) bprm->p))>>PAGE_SHIFT)) {
 		kmem_cache_free(vm_area_cachep, mpnt);
 		return -ENOMEM;
 	}

