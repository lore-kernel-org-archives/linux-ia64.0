From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Wed, 22 Oct 2003 03:45:47 +0000
Subject: [PATCH] Re: Gate DSO not building properly?
MIME-Version: 1
Content-Type: multipart/mixed; boundary="2oS5YaxWCcQjTEyO"
Message-Id: <marc-linux-ia64-106679437709356@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--2oS5YaxWCcQjTEyO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Oct 21, 2003 at 04:10:51PM +1000, Ian Wienand wrote:
> arch/ia64/kernel/gate-data.S:1: Warning: setting incorrect section
> attributes for .data.gate

I figured out why (sorry if it's obvious); gas matches anything with
prefix '.data.' as a data special section and flags it as 'SHF_ALLOC +
SHF_WRITE' as per ELF [*].  Issuing 

.section .data.gate, "ax"

thus conflicts as it's assumed to be an extension of a .data section.

Should this even be in data at all, considering it's code?  What about
something along the lines of the attached patch which puts it in it's
own section?

-i
ianw@gelato.unsw.edu.au
http://www.gelato.unsw.edu.au

[*] For those who don't know, the exact rules about what sections and
how prefixes get matched are in bfd/elf-bfd.h(struct
bfd_elf_special_section) and bfd/elf.c in binutils.

--2oS5YaxWCcQjTEyO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="gate-wrapper.patch"

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1356  -> 1.1358 
#	arch/ia64/kernel/gate-data.S	1.1     -> 1.3     arch/ia64/kernel/gate-wrapper.S (moved)
#	arch/ia64/kernel/vmlinux.lds.S	1.38    -> 1.40   
#	arch/ia64/kernel/Makefile	1.26    -> 1.27   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/10/22	ianw@lemon.gelato.unsw.edu.au	1.1357
# The kernel DSO should not be in a .data section, so put it in its own.
# --------------------------------------------
# 03/10/22	ianw@lemon.gelato.unsw.edu.au	1.1358
# Separate out .linux_gate section
# --------------------------------------------
#
diff -Nru a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
--- a/arch/ia64/kernel/Makefile	Wed Oct 22 13:37:42 2003
+++ b/arch/ia64/kernel/Makefile	Wed Oct 22 13:37:42 2003
@@ -4,7 +4,7 @@
 
 extra-y	:= head.o init_task.o vmlinux.lds.s
 
-obj-y := acpi.o entry.o efi.o efi_stub.o gate-data.o fsys.o ia64_ksyms.o irq.o irq_ia64.o	\
+obj-y := acpi.o entry.o efi.o efi_stub.o gate-wrapper.o fsys.o ia64_ksyms.o irq.o irq_ia64.o	\
 	 irq_lsapic.o ivt.o machvec.o pal.o patch.o process.o perfmon.o ptrace.o sal.o		\
 	 semaphore.o setup.o signal.o sys_ia64.o time.o traps.o unaligned.o unwind.o
 
@@ -41,7 +41,7 @@
 $(obj)/gate-syms.o: $(src)/gate.lds.s $(obj)/gate.o FORCE
 	$(call if_changed,gate)
 
-# gate-data.o contains the gate DSO image as data in section .data.gate.
+# gate-wrapper.o contains the gate DSO image in the section .linux_gate.
 # We must build gate.so before we can assemble it.
 # Note: kbuild does not track this dependency due to usage of .incbin
-$(obj)/gate-data.o: $(obj)/gate.so
+$(obj)/gate-wrapper.o: $(obj)/gate.so
diff -Nru a/arch/ia64/kernel/gate-data.S b/arch/ia64/kernel/gate-data.S
--- a/arch/ia64/kernel/gate-data.S	Wed Oct 22 13:37:42 2003
+++ /dev/null	Wed Dec 31 16:00:00 1969
@@ -1,3 +0,0 @@
-	.section .data.gate, "ax"
-
-	.incbin "arch/ia64/kernel/gate.so"
diff -Nru a/arch/ia64/kernel/gate-wrapper.S b/arch/ia64/kernel/gate-wrapper.S
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/arch/ia64/kernel/gate-wrapper.S	Wed Oct 22 13:37:42 2003
@@ -0,0 +1,8 @@
+/*
+ * This creates gate-wrapper.o which is an 
+ * object file that gets put into vmlinux.
+ * All it contains is the gate DSO
+ */
+	.section .linux_gate, "ax"
+
+	.incbin "arch/ia64/kernel/gate.so"
diff -Nru a/arch/ia64/kernel/vmlinux.lds.S b/arch/ia64/kernel/vmlinux.lds.S
--- a/arch/ia64/kernel/vmlinux.lds.S	Wed Oct 22 13:37:42 2003
+++ b/arch/ia64/kernel/vmlinux.lds.S	Wed Oct 22 13:37:42 2003
@@ -161,17 +161,26 @@
   .data.init_task : AT(ADDR(.data.init_task) - LOAD_OFFSET)
 	{ *(.data.init_task) }
 
+  /* Page aligned data */
   .data.page_aligned : AT(ADDR(.data.page_aligned) - LOAD_OFFSET)
-        { *(__special_page_section)
-	  __start_gate_section = .;
-	  *(.data.gate)
-	  __stop_gate_section = .;
+        { 
+		*(__special_page_section)
+		*(.data.page_aligned)
 	}
-  . = ALIGN(PAGE_SIZE);		/* make sure the gate page doesn't expose kernel data */
-
+  . = ALIGN(PAGE_SIZE);
+	
   .data.cacheline_aligned : AT(ADDR(.data.cacheline_aligned) - LOAD_OFFSET)
         { *(.data.cacheline_aligned) }
 
+  /* The linux-gate.so shared object */
+  .linux_gate : AT(ADDR(.linux_gate) - LOAD_OFFSET)
+        { __start_gate_section = .;
+	  *(.linux_gate)
+	  __stop_gate_section = .;
+	}
+  . = ALIGN(PAGE_SIZE);		/* make sure the gate page doesn't expose kernel data */
+
+	
   /* Per-cpu data: */
   . = ALIGN(PERCPU_PAGE_SIZE);
   __phys_per_cpu_start = .;

--2oS5YaxWCcQjTEyO--
