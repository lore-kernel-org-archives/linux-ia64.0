From: "Sluder, Charles" <Charles.Sluder@UNISYS.com>
Date: Fri, 01 Nov 2002 22:14:43 +0000
Subject: [Linux-ia64] [PATCH]ACPI fACS global lock & virtual memmap
Message-Id: <marc-linux-ia64-105590709805326@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We recently moved from 2.4.9 to 2.4.19.  We encountered several problems
when trying to boot the kernel.

The first problem was a panic in put_gate_page(). The panic only occurs with
CONFIG_VIRTUAL_MEMMAP enabled. The panic results because there is not a pte
for the kernel data section.  We traced this back and found that
efi_memmap_walk() was indiscriminately "trimming" chunks out of the first
96MB of memory in the efi memory map. The problem appears to be that the
first_non_wb_addr variable is not being advanced properly as the code walks
through the efi memory descriptors. On the next pass through the outer loop
after a hole is encountered in the memmap, first_non_wb_addr is usually
pointing at one of the memory descriptors in the previous contiguous
segment. It calls the functions to trim the memory descriptor without taking
the memory descriptor previous to that into account. Basically the code goes
through a contiguous segment, finds a hole, and then, on the next pass,
trims a bunch of memory out of the contiguous segment. The problem only
occurs if there are numerous holes in the efi memory map. The panic will not
occur on a tiger.  The patch sets first_non_wb_addr to either the first non
write back address it finds or to the  start address in the first memory
descriptor after a hole. We do not fully understand all the uses for this
routine and are therefore not certain that this is the correct way to fix
this problem.

The second problem encountered is a hang trying to acquire the FACS global
lock. The arguments passed to the acquire and release macros, for the global
lock, changed slightly between 2.4.9 and 2.4.18. The result appears to be
that the address to the pointer to the global lock is being passed to the
macros as the lock address instead of the global lock address. We tried
several things to force the correct values to be passed to the macro, but
the only thing that has worked is to change the memory constraint on the
GLptr to a register constraint and modify the macro appropriately.  This
problem only occurs if the firmware supports the FACS global lock. The
problem will not occur on a tiger.

The third problem was an unsupported data reference fault when executing the
cmpxchg instruction, in the macros to acquire and release the above lock.
The global lock address passed to the macros was uncached. We have moved the
lock address into the cached memory region.  The lock is only used by these
macros so we don't belive this causes a problem unless there is something
lurking in the SAL that we are unaware of.

Comment and discussion are welcome. I am sure we would get it even if it
wasn't :-).

-chuck

Charles Sluder
Enterprise Unix Group
Unisys Corp.


diff -Naur UL.base/arch/ia64/kernel/efi.c linux.work/arch/ia64/kernel/efi.c
--- UL.base/arch/ia64/kernel/efi.c	2002-10-21 08:52:13.000000000 -0700
+++ linux.work/arch/ia64/kernel/efi.c	2002-11-01 14:01:21.000000000 -0800
@@ -247,13 +249,19 @@
 				if (check_md->phys_addr < granule_addr)
 					continue;
 
-				if (!(check_md->attribute & EFI_MEMORY_WB))
+
+				if (!(check_md->attribute & EFI_MEMORY_WB)){
+					first_non_wb_addr check_md->phys_addr;
 					break;	/* hit a non-WB region; stop
search */
+				}
 
-				if (check_md->phys_addr !first_non_wb_addr)
+				if (check_md->phys_addr !first_non_wb_addr){
+					first_non_wb_addr check_md->phys_addr;
 					break;	/* hit a memory hole; stop
search */
+				}
 
 				first_non_wb_addr += check_md->num_pages <<
EFI_PAGE_SHIFT;
 			}
 			/* round it down to the previous granule-boundary:
*/
 			first_non_wb_addr &= -IA64_GRANULE_SIZE;

 
diff -Naur UL.base/drivers/acpi/tables/tbconvrt.c
linux.work/drivers/acpi/tables/tbconvrt.c
--- UL.base/drivers/acpi/tables/tbconvrt.c	2002-10-21
08:52:13.000000000 -0700
+++ linux.work/drivers/acpi/tables/tbconvrt.c	2002-11-01
12:16:08.000000000 -0800
@@ -435,7 +435,8 @@
 
 	/* Copy fields to the new FACS */
 
-	acpi_gbl_common_fACS.global_lock = &(acpi_gbl_FACS->global_lock);
+	/* Make sure it's cached identity-mapped */
+	acpi_gbl_common_fACS.global_lock = (void
*)((ulong)&(acpi_gbl_FACS->global_lock) | PAGE_OFFSET);
 
 	if ((acpi_gbl_RSDP->revision < 2) ||
 		(acpi_gbl_FACS->length < 32) ||
 
diff -Naur UL.base/include/asm-ia64/acpi.h
linux.work/include/asm-ia64/acpi.h
--- UL.base/include/asm-ia64/acpi.h	2002-10-21 08:52:13.000000000 -0700
+++ linux.work/include/asm-ia64/acpi.h	2002-11-01 12:24:18.000000000 -0800
@@ -54,9 +54,10 @@
 #define ACPI_ENABLE_IRQS()  __sti()
 #define ACPI_FLUSH_CPU_CACHE()
 
+
 #define ACPI_ACQUIRE_GLOBAL_LOCK(GLptr, Acq) \
 	do { \
-	__asm__ volatile ("1:  ld4      r29=%1\n"  \
+	__asm__ volatile ("1:  ld4      r29=[%1]\n"  \
 		";;\n"                  \
 		"mov    ar.ccv=r29\n"   \
 		"mov    r2=r29\n"       \
@@ -68,7 +69,7 @@
 		";;\n"                  \
 		"add    r29=r29,r30\n"  \
 		";;\n"                  \
-		"cmpxchg4.acq   r30=%1,r29,ar.ccv\n" \
+		"cmpxchg4.acq   r30=[%1],r29,ar.ccv\n" \
 		";;\n"                  \
 		"cmp.eq p6,p7=r2,r30\n" \
 		"(p7) br.dpnt.few 1b\n" \
@@ -76,24 +77,24 @@
 		";;\n"                  \
 		"(p8) mov %0=-1\n"      \
 		"(p9) mov %0=r0\n"      \
-		:"=r"(Acq):"m"(GLptr):"r2","r29","r30","memory"); \
+
:"=r"(Acq):"r"(GLptr):"r2","r29","r30","p6","p7","p8","p9","ar.ccv","memory"
); \  
 	} while (0)
 
 #define ACPI_RELEASE_GLOBAL_LOCK(GLptr, Acq) \
 	do { \
-	__asm__ volatile ("1:  ld4      r29=%1\n" \
+        __asm__ volatile ("1:  ld4      r29=[%1]\n" \ 
 		";;\n"                  \
 		"mov    ar.ccv=r29\n"   \
 		"mov    r2=r29\n"       \
 		"and    r29=-4,r29\n"   \
 		";;\n"                  \
-		"cmpxchg4.acq   r30=%1,r29,ar.ccv\n" \
+                "cmpxchg4.rel   r30=[%1],r29,ar.ccv\n" \    
 		";;\n"                  \
 		"cmp.eq p6,p7=r2,r30\n" \
 		"(p7) br.dpnt.few 1b\n" \
 		"and    %0=1,r2\n"      \
 		";;\n"                  \
-		:"=r"(Acq):"m"(GLptr):"r2","r29","r30","memory"); \
+
:"=r"(Acq):"r"(GLptr):"r2","r29","r30","p6","p7","ar.ccv","memory"); \    
 	} while (0)
 
 const char *acpi_get_sysname (void);

