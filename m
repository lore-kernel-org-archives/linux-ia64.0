From: Horms <horms@verge.net.au>
Date: Fri, 01 Dec 2006 06:08:53 +0000
Subject: Re: [Fastboot] [PATCH]send slave cpus to SAL slave loop on crash (IA64)
Message-Id: <20061201060852.GA13622@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Nov 21, 2006 at 07:13:56AM +0800, Zou Nan hai wrote:
> This patch make normal "kexec -l" first try physical address suggested
> by vmlinux. 
> 
> If there is no enough memory, kexec tools will search /proc/iomem and
> find a place to put the new kernel.
> 
> This is necessary for "kexec -l" to work on SN platform.
> 
> Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>
> 

Hi Nan hai, 

sorry for not responding sooner.

I have take a look at your patch with an eye to including it into 
kexec-tools-testing. It does seem like a good feature.

Below is an updated version of the patch that cleans up your
implementation a little. In particular.

* update_loaded_segments() returns -1 on error, 0 on success
  - amongst other things the previous incarnation could return nothing
    at all in once case.
* else { if () { ; } } -> else if () { ; }
* < 80 columns wide
* removed trailing whitespace

Is it ok to apply this incarntation of the patch?
I can make my changes a second patch if you prefer.

Signed-off-by: Simon Horman <horms@verge.net.au>

diff --git a/kexec/arch/ia64/kexec-elf-ia64.c b/kexec/arch/ia64/kexec-elf-ia64.c
index bd2350c..e9f60ea 100644
--- a/kexec/arch/ia64/kexec-elf-ia64.c
+++ b/kexec/arch/ia64/kexec-elf-ia64.c
@@ -86,7 +86,8 @@ void elf_ia64_usage(void)
 
 /* Move the crash kerenl physical offset to reserved region
  */
-static void move_loaded_segments(struct kexec_info *info, struct mem_ehdr *ehdr)
+void move_loaded_segments(struct kexec_info *info, struct mem_ehdr *ehdr,
+			  unsigned long addr)
 {
 	int i;
 	long offset;
@@ -94,7 +95,7 @@ static void move_loaded_segments(struct kexec_info *info, struct mem_ehdr *ehdr)
 	for(i = 0; i < ehdr->e_phnum; i++) {
 		phdr = &ehdr->e_phdr[i];
 		if (phdr->p_type = PT_LOAD) {
-			offset = mem_min - phdr->p_paddr;
+			offset = addr - phdr->p_paddr;
 			break;
 		}
 	}
@@ -189,7 +190,10 @@ int elf_ia64_load(int argc, char **argv, const char *buf, off_t len,
 			free_elf_info(&ehdr);
 			return -1;
 		}
-		move_loaded_segments(info, &ehdr);
+		move_loaded_segments(info, &ehdr, mem_min);
+	} else if (update_loaded_segments(info, &ehdr) < 0) {
+		fprintf(stderr, "Failed to place kernel\n");
+		return -1;
 	}
 
 	entry = ehdr.e_entry;
diff --git a/kexec/arch/ia64/kexec-ia64.c b/kexec/arch/ia64/kexec-ia64.c
index 48fad60..506d37d 100644
--- a/kexec/arch/ia64/kexec-ia64.c
+++ b/kexec/arch/ia64/kexec-ia64.c
@@ -29,12 +29,15 @@
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
+static int memory_ranges;
 
 /* Reserve range for EFI memmap and Boot parameter */
 static int split_range(int range, unsigned long start, unsigned long end)
@@ -73,7 +76,6 @@ int get_memory_ranges(struct memory_range **range, int *ranges,
 				unsigned long kexec_flags)
 {
 	const char iomem[]= "/proc/iomem";
-	int memory_ranges = 0;
 	char line[MAX_LINE];
 	FILE *fp;
 	fp = fopen(iomem, "r");
@@ -209,6 +211,45 @@ int arch_compat_trampoline(struct kexec_info *info)
 	return 0;
 }
 
+int update_loaded_segments(struct kexec_info *info, struct mem_ehdr *ehdr)
+{
+	int i;
+	struct mem_phdr *phdr;
+	unsigned long start_addr = ULONG_MAX, end_addr = 0;
+	unsigned long align = 1UL<<26; /* 64M */
+	unsigned long start, end;
+
+	for (i = 0; i < ehdr->e_phnum; i++) {
+		phdr = &ehdr->e_phdr[i];
+		if (phdr->p_type != PT_LOAD)
+			continue;
+		if (phdr->p_paddr < start_addr)
+			start_addr = phdr->p_paddr;
+		if ((phdr->p_paddr + phdr->p_memsz) > end_addr)
+			end_addr = phdr->p_paddr + phdr->p_memsz;
+	}
+
+	for (i = 0; i < memory_ranges && memory_range[i].start <= start_addr;
+	     i++) {
+		if (memory_range[i].type = RANGE_RAM &&
+		    memory_range[i].end > end_addr)
+			return 0;
+	}
+
+	for (i = 0; i < memory_ranges; i++) {
+		if (memory_range[i].type != RANGE_RAM)
+			continue;
+		start = (memory_range[i].start + align - 1) & ~(align - 1);
+		end = memory_range[i].end;
+		if (end > start && (end - start) > (end_addr - start_addr)) {
+		    move_loaded_segments(info, ehdr, start);
+			return 0;
+		}
+	}
+
+	return -1;
+}
+
 void arch_update_purgatory(struct kexec_info *info)
 {
 }
diff --git a/kexec/arch/ia64/kexec-ia64.h b/kexec/arch/ia64/kexec-ia64.h
index 62d05c1..7995307 100644
--- a/kexec/arch/ia64/kexec-ia64.h
+++ b/kexec/arch/ia64/kexec-ia64.h
@@ -7,6 +7,10 @@ int elf_ia64_probe(const char *buf, off_t len);
 int elf_ia64_load(int argc, char **argv, const char *buf, off_t len,
 	struct kexec_info *info);
 void elf_ia64_usage(void);
+int update_loaded_segments(struct kexec_info *info, struct mem_ehdr *ehdr);
+void move_loaded_segments(struct kexec_info *info, struct mem_ehdr *ehdr,
+			  unsigned long addr);
+
 #define MAX_MEMORY_RANGES 1024
 #define EFI_PAGE_SIZE	  (1UL<<12)
 #define ELF_PAGE_SIZE	  (1UL<<16)
