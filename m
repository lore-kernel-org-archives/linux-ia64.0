From: Zou Nan hai <nanhai.zou@intel.com>
Date: Mon, 20 Nov 2006 23:13:56 +0000
Subject: Re: [PATCH]send slave cpus to SAL slave loop on crash (IA64)
Message-Id: <1164064436.2589.10.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
References: <4546623D.5000105@engr.sgi.com>
In-Reply-To: <4546623D.5000105@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2006-11-21 at 07:33, Jay Lan wrote:
> Zou, Nanhai wrote:
> >> We do not rely on machine crash on CPU 0 any more. If the
> >> crashing CPU is not cpu 0 and the cpu 0 not being returned to
> >> the slave loop, this case is handled by our PROM now.
> >>
> >> However, if somebody tries to boot up a production kernel using
> '-le'
> >> option _after_ the kexec'ed kernel is up running, the third kernel
> >> would not boot unless we boot up the second kernel with cpu 0. I
> >> posted a question on "if running 'kexec -le' on a kexec'ed kdump
> >> kernel is legal" earlier and Vivek responded saying the scenario
> >> is not guranteed to work. So, i think we are fine here.
> >>     
> >
> >   Ok, so with this patch and the PROM fix, on a SN system,
> >   1. Kdump -> 2nd kernel works.
> >   2. Kdump -> 2nd kernel -> Kexec to third kernel will not work.
> >   3. Kexec -> 2nd Kernel -> Kexec -> 3rd kernel works?
> >   4. Kexec -> 2nd Kernel -> Kdump -> 3rd kernel works?
> >
> >   I think if scenario 1, 3 and 4 works it will be ok. Scenario 2 is
> not so useful I guess.
> >   
> 
> With the patch Nanhai sent to me to fix '-l' option on SN system,
> now scenario 1, 3 and 4 all works. Of course, you need to include
> 'crashkernel' parameter in "append" option when you do 'kexec -l'
> in order for scenario #4 to work. You do not need crashkernel
> parameter for #3 though.
> 
> Thanks,
> - jay
> 
> 

This is the patch,
This patch make normal "kexec -l" first try physical address suggested
by vmlinux. 

If there is no enough memory, kexec tools will search /proc/iomem and
find a place to put the new kernel.

This is necessary for "kexec -l" to work on SN platform.

Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>

diff -Nraup a/kexec/arch/ia64/kexec-elf-ia64.c b/kexec/arch/ia64/kexec-elf-ia64.c
--- a/kexec/arch/ia64/kexec-elf-ia64.c	2006-11-20 00:56:54.000000000 -0500
+++ b/kexec/arch/ia64/kexec-elf-ia64.c	2006-11-20 20:49:21.000000000 -0500
@@ -84,7 +84,8 @@ void elf_ia64_usage(void)
 
 /* Move the crash kerenl physical offset to reserved region
  */
-static void move_loaded_segments(struct kexec_info *info, struct mem_ehdr *ehdr)
+void move_loaded_segments(struct kexec_info *info, struct mem_ehdr *ehdr, 
+	unsigned long addr)
 {
 	int i;
 	long offset;
@@ -92,7 +93,7 @@ static void move_loaded_segments(struct 
 	for(i = 0; i < ehdr->e_phnum; i++) {
 		phdr = &ehdr->e_phdr[i];
 		if (phdr->p_type = PT_LOAD) {
-			offset = mem_min - phdr->p_paddr;
+			offset = addr - phdr->p_paddr;
 			break;
 		}
 	}
@@ -168,7 +169,12 @@ int elf_ia64_load(int argc, char **argv,
 			fprintf(stderr, "Failed to find crash kernel region in /proc/iomem\n");
 		return -1;
 		}
-		move_loaded_segments(info, &ehdr);
+		move_loaded_segments(info, &ehdr, mem_min);
+	} else {
+		if (update_loaded_segments(info, &ehdr)) {
+			fprintf(stderr, "Failed to place kernel\n");
+			return -1;
+		}
 	}
 
 	entry = ehdr.e_entry;
diff -Nraup a/kexec/arch/ia64/kexec-ia64.c b/kexec/arch/ia64/kexec-ia64.c
--- a/kexec/arch/ia64/kexec-ia64.c	2006-11-20 00:54:38.000000000 -0500
+++ b/kexec/arch/ia64/kexec-ia64.c	2006-11-20 20:49:21.000000000 -0500
@@ -29,13 +29,15 @@
 #include <getopt.h>
 #include <sched.h>
 #include <sys/utsname.h>
+#include <limits.h>
 #include "../../kexec.h"
 #include "../../kexec-syscall.h"
+#include "elf.h"
 #include "kexec-ia64.h"
 #include <arch/options.h>
 
 static struct memory_range memory_range[MAX_MEMORY_RANGES];
-
+static int memory_ranges;
 /* Reserve range for EFI memmap and Boot parameter */
 static int split_range(int range, unsigned long start, unsigned long end)
 {
@@ -73,7 +75,6 @@ int get_memory_ranges(struct memory_rang
 				unsigned long kexec_flags)
 {
 	const char iomem[]= "/proc/iomem";
-	int memory_ranges = 0;
 	char line[MAX_LINE];
 	FILE *fp;
 	fp = fopen(iomem, "r");
@@ -209,6 +210,45 @@ int arch_compat_trampoline(struct kexec_
 	return 0;
 }
 
+int update_loaded_segments(struct kexec_info *info, struct mem_ehdr *ehdr)
+{
+	int i;
+	struct mem_phdr *phdr;
+	unsigned long start_addr = ULONG_MAX, end_addr = 0;
+	unsigned long align = 1UL<<26; // 64M
+	for(i = 0; i < ehdr->e_phnum; i++) {
+		phdr = &ehdr->e_phdr[i];
+		if (phdr->p_type = PT_LOAD) {
+			if (phdr->p_paddr < start_addr) 
+				start_addr = phdr->p_paddr;
+			if ((phdr->p_paddr + phdr->p_memsz) > end_addr)
+				end_addr = phdr->p_paddr + phdr->p_memsz;
+		}
+
+	}
+	
+	for (i = 0; i < memory_ranges 
+		&& memory_range[i].start <= start_addr; i++) {
+		if (memory_range[i].type = RANGE_RAM &&
+			memory_range[i].end > end_addr)
+		return;
+	}
+
+	for (i = 0; i < memory_ranges; i++) {
+		if (memory_range[i].type = RANGE_RAM) {
+			unsigned long start = 
+				(memory_range[i].start + align - 1)&~(align - 1);
+			unsigned long end = memory_range[i].end;
+			if (end > start && 
+					(end - start) > (end_addr - start_addr)) {
+				move_loaded_segments(info, ehdr, start);
+				return 0;
+			}
+		}
+	}
+	return 1;
+}
+
 void arch_update_purgatory(struct kexec_info *info)
 {
 }
diff -Nraup a/kexec/arch/ia64/kexec-ia64.h b/kexec/arch/ia64/kexec-ia64.h
--- a/kexec/arch/ia64/kexec-ia64.h	2006-10-24 21:51:49.000000000 -0400
+++ b/kexec/arch/ia64/kexec-ia64.h	2006-11-20 20:49:43.000000000 -0500
@@ -7,6 +7,10 @@ int elf_ia64_probe(const char *buf, off_
 int elf_ia64_load(int argc, char **argv, const char *buf, off_t len,
 	struct kexec_info *info);
 void elf_ia64_usage(void);
+int update_loaded_segments(struct kexec_info *info, struct mem_ehdr *ehdr);
+void move_loaded_segments(struct kexec_info *info, struct mem_ehdr *ehdr,
+        unsigned long addr);
+
 #define MAX_MEMORY_RANGES 1024
 #define EFI_PAGE_SIZE	  (1UL<<12)
 #define ELF_PAGE_SIZE	  (1UL<<16)

