From: Xunlei Pang <xlpang@redhat.com>
Date: Thu, 27 Apr 2017 08:16:59 +0000
Subject: [PATCH v5 1/3] kexec: Move vmcoreinfo out of the kernel's .bss section
Message-Id: <1493281021-20737-1-git-send-email-xlpang@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, kexec@lists.infradead.org
Cc: akpm@linux-foundation.org, Eric Biederman <ebiederm@xmission.com>, Dave Young <dyoung@redhat.com>, Baoquan He <bhe@redhat.com>, Petr Tesarik <ptesarik@suse.cz>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Michael Holzheu <holzheu@linux.vnet.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-ia64@vger.kernel.org, Xunlei Pang <xlpang@redhat.com>, Juergen Gross <jgross@suse.com>

As Eric said,
"what we need to do is move the variable vmcoreinfo_note out
of the kernel's .bss section.  And modify the code to regenerate
and keep this information in something like the control page.

Definitely something like this needs a page all to itself, and ideally
far away from any other kernel data structures.  I clearly was not
watching closely the data someone decided to keep this silly thing
in the kernel's .bss section."

This patch allocates extra pages for these vmcoreinfo_XXX variables,
one advantage is that it enhances some safety of vmcoreinfo, because
vmcoreinfo now is kept far away from other kernel data structures.

Cc: Juergen Gross <jgross@suse.com>
Suggested-by: Eric Biederman <ebiederm@xmission.com>
Tested-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>
Reviewed-by: Juergen Gross <jgross@suse.com>
Signed-off-by: Xunlei Pang <xlpang@redhat.com>
---
v4->v5:
Changed VMCOREINFO_BYTES definition to PAGE_SIZE according to Dave's comment

v3->v4:
-Rebased on the latest linux-next
-Handle S390 vmcoreinfo_note properly
-Handle the newly-added xen/mmu_pv.c

 arch/ia64/kernel/machine_kexec.c |  5 -----
 arch/s390/kernel/machine_kexec.c |  1 +
 arch/s390/kernel/setup.c         |  6 ------
 arch/x86/kernel/crash.c          |  2 +-
 arch/x86/xen/mmu_pv.c            |  4 ++--
 include/linux/crash_core.h       |  4 ++--
 kernel/crash_core.c              | 26 ++++++++++++++++++++++----
 kernel/ksysfs.c                  |  2 +-
 8 files changed, 29 insertions(+), 21 deletions(-)

diff --git a/arch/ia64/kernel/machine_kexec.c b/arch/ia64/kernel/machine_kexec.c
index 599507b..c14815d 100644
--- a/arch/ia64/kernel/machine_kexec.c
+++ b/arch/ia64/kernel/machine_kexec.c
@@ -163,8 +163,3 @@ void arch_crash_save_vmcoreinfo(void)
 #endif
 }
 
-phys_addr_t paddr_vmcoreinfo_note(void)
-{
-	return ia64_tpa((unsigned long)(char *)&vmcoreinfo_note);
-}
-
diff --git a/arch/s390/kernel/machine_kexec.c b/arch/s390/kernel/machine_kexec.c
index 49a6bd4..3d0b14a 100644
--- a/arch/s390/kernel/machine_kexec.c
+++ b/arch/s390/kernel/machine_kexec.c
@@ -246,6 +246,7 @@ void arch_crash_save_vmcoreinfo(void)
 	VMCOREINFO_SYMBOL(lowcore_ptr);
 	VMCOREINFO_SYMBOL(high_memory);
 	VMCOREINFO_LENGTH(lowcore_ptr, NR_CPUS);
+	mem_assign_absolute(S390_lowcore.vmcore_info, paddr_vmcoreinfo_note());
 }
 
 void machine_shutdown(void)
diff --git a/arch/s390/kernel/setup.c b/arch/s390/kernel/setup.c
index 3ae756c..3d1d808 100644
--- a/arch/s390/kernel/setup.c
+++ b/arch/s390/kernel/setup.c
@@ -496,11 +496,6 @@ static void __init setup_memory_end(void)
 	pr_notice("The maximum memory size is %luMB\n", memory_end >> 20);
 }
 
-static void __init setup_vmcoreinfo(void)
-{
-	mem_assign_absolute(S390_lowcore.vmcore_info, paddr_vmcoreinfo_note());
-}
-
 #ifdef CONFIG_CRASH_DUMP
 
 /*
@@ -939,7 +934,6 @@ void __init setup_arch(char **cmdline_p)
 #endif
 
 	setup_resources();
-	setup_vmcoreinfo();
 	setup_lowcore();
 	smp_fill_possible_mask();
 	cpu_detect_mhz_feature();
diff --git a/arch/x86/kernel/crash.c b/arch/x86/kernel/crash.c
index 22217ec..44404e2 100644
--- a/arch/x86/kernel/crash.c
+++ b/arch/x86/kernel/crash.c
@@ -457,7 +457,7 @@ static int prepare_elf64_headers(struct crash_elf_data *ced,
 	bufp += sizeof(Elf64_Phdr);
 	phdr->p_type = PT_NOTE;
 	phdr->p_offset = phdr->p_paddr = paddr_vmcoreinfo_note();
-	phdr->p_filesz = phdr->p_memsz = sizeof(vmcoreinfo_note);
+	phdr->p_filesz = phdr->p_memsz = VMCOREINFO_NOTE_SIZE;
 	(ehdr->e_phnum)++;
 
 #ifdef CONFIG_X86_64
diff --git a/arch/x86/xen/mmu_pv.c b/arch/x86/xen/mmu_pv.c
index 9d9ae66..35543fa 100644
--- a/arch/x86/xen/mmu_pv.c
+++ b/arch/x86/xen/mmu_pv.c
@@ -2723,8 +2723,8 @@ void xen_destroy_contiguous_region(phys_addr_t pstart, unsigned int order)
 phys_addr_t paddr_vmcoreinfo_note(void)
 {
 	if (xen_pv_domain())
-		return virt_to_machine(&vmcoreinfo_note).maddr;
+		return virt_to_machine(vmcoreinfo_note).maddr;
 	else
-		return __pa_symbol(&vmcoreinfo_note);
+		return __pa(vmcoreinfo_note);
 }
 #endif /* CONFIG_KEXEC_CORE */
diff --git a/include/linux/crash_core.h b/include/linux/crash_core.h
index eb71a70..ec9d415 100644
--- a/include/linux/crash_core.h
+++ b/include/linux/crash_core.h
@@ -14,7 +14,7 @@
 				     CRASH_CORE_NOTE_NAME_BYTES +	\
 				     CRASH_CORE_NOTE_DESC_BYTES)
 
-#define VMCOREINFO_BYTES	   (4096)
+#define VMCOREINFO_BYTES	   PAGE_SIZE
 #define VMCOREINFO_NOTE_NAME	   "VMCOREINFO"
 #define VMCOREINFO_NOTE_NAME_BYTES ALIGN(sizeof(VMCOREINFO_NOTE_NAME), 4)
 #define VMCOREINFO_NOTE_SIZE	   ((CRASH_CORE_NOTE_HEAD_BYTES * 2) +	\
@@ -53,7 +53,7 @@
 #define VMCOREINFO_PHYS_BASE(value) \
 	vmcoreinfo_append_str("PHYS_BASE=%lx\n", (unsigned long)value)
 
-extern u32 vmcoreinfo_note[VMCOREINFO_NOTE_SIZE/4];
+extern u32 *vmcoreinfo_note;
 extern size_t vmcoreinfo_size;
 extern size_t vmcoreinfo_max_size;
 
diff --git a/kernel/crash_core.c b/kernel/crash_core.c
index fcbd568..2837d61 100644
--- a/kernel/crash_core.c
+++ b/kernel/crash_core.c
@@ -14,10 +14,10 @@
 #include <asm/sections.h>
 
 /* vmcoreinfo stuff */
-static unsigned char vmcoreinfo_data[VMCOREINFO_BYTES];
-u32 vmcoreinfo_note[VMCOREINFO_NOTE_SIZE/4];
+static unsigned char *vmcoreinfo_data;
 size_t vmcoreinfo_size;
-size_t vmcoreinfo_max_size = sizeof(vmcoreinfo_data);
+size_t vmcoreinfo_max_size = VMCOREINFO_BYTES;
+u32 *vmcoreinfo_note;
 
 /*
  * parsing the "crashkernel" commandline
@@ -326,6 +326,9 @@ static void update_vmcoreinfo_note(void)
 
 void crash_save_vmcoreinfo(void)
 {
+	if (!vmcoreinfo_note)
+		return;
+
 	vmcoreinfo_append_str("CRASHTIME=%ld\n", get_seconds());
 	update_vmcoreinfo_note();
 }
@@ -356,11 +359,26 @@ void __weak arch_crash_save_vmcoreinfo(void)
 
 phys_addr_t __weak paddr_vmcoreinfo_note(void)
 {
-	return __pa_symbol((unsigned long)(char *)&vmcoreinfo_note);
+	return __pa(vmcoreinfo_note);
 }
 
 static int __init crash_save_vmcoreinfo_init(void)
 {
+	vmcoreinfo_data = (unsigned char *)get_zeroed_page(GFP_KERNEL);
+	if (!vmcoreinfo_data) {
+		pr_warn("Memory allocation for vmcoreinfo_data failed\n");
+		return -ENOMEM;
+	}
+
+	vmcoreinfo_note = alloc_pages_exact(VMCOREINFO_NOTE_SIZE,
+						GFP_KERNEL | __GFP_ZERO);
+	if (!vmcoreinfo_note) {
+		free_page((unsigned long)vmcoreinfo_data);
+		vmcoreinfo_data = NULL;
+		pr_warn("Memory allocation for vmcoreinfo_note failed\n");
+		return -ENOMEM;
+	}
+
 	VMCOREINFO_OSRELEASE(init_uts_ns.name.release);
 	VMCOREINFO_PAGESIZE(PAGE_SIZE);
 
diff --git a/kernel/ksysfs.c b/kernel/ksysfs.c
index 23cd706..c40a4e5 100644
--- a/kernel/ksysfs.c
+++ b/kernel/ksysfs.c
@@ -134,7 +134,7 @@ static ssize_t vmcoreinfo_show(struct kobject *kobj,
 {
 	phys_addr_t vmcore_base = paddr_vmcoreinfo_note();
 	return sprintf(buf, "%pa %x\n", &vmcore_base,
-		       (unsigned int)sizeof(vmcoreinfo_note));
+			(unsigned int)VMCOREINFO_NOTE_SIZE);
 }
 KERNEL_ATTR_RO(vmcoreinfo);
 
-- 
1.8.3.1

