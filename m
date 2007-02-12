From: Bernhard Walle <bwalle@suse.de>
Date: Mon, 12 Feb 2007 21:49:34 +0000
Subject: Re: [Fastboot] Zero size /proc/vmcore on ia64
Message-Id: <20070212214934.GA2961@strauss.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070212185756.GA22524@strauss.suse.de>
In-Reply-To: <20070212185756.GA22524@strauss.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

* Bernhard Walle <bwalle@suse.de> [2007-02-12 19:57]:
> * Zou, Nanhai <nanhai.zou@intel.com> [2007-02-09 00:45]:
> >  I have not implement serial print in purgatory code yet, see
> >  comments in purgatory/arch/ia64/console-ia64.c However from your
> >  print, I can see last 2 entries of efi mem map are corrupt. 
> 
> I have the same problem (corrupted memory map entries), and the cause
> was in kexec-tools, patch below. I'm not sure if the fix is right, at
> least the problem is the uninitialised value of size. :)

But that patch doesn't fix the zero-size problem, it just fixes the
invalid EFI map problem. That patch (against kexec-tools, not against
the kernel) fixes both.

The problem is simply that the space for the core header doesn't
occupy a EFI page.

Signed-off-by: Bernhard Walle <bwalle@suse.de>

---
 crashdump-ia64.c |   14 ++++++++++----
 kexec-ia64.h     |    6 +++++-
 2 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/kexec/arch/ia64/crashdump-ia64.c b/kexec/arch/ia64/crashdump-ia64.c
index 14e95a6..e3d8b41 100644
--- a/kexec/arch/ia64/crashdump-ia64.c
+++ b/kexec/arch/ia64/crashdump-ia64.c
@@ -220,8 +220,8 @@ int load_crashdump_segments(struct kexec_info *info, struct mem_ehdr *ehdr,
 {
 	struct memory_range *mem_range;
 	int nr_ranges;
-	unsigned long sz;
-	size_t size;
+	unsigned long sz, memsz;
+	size_t size = 0;
 	void *tmp;
 	if (info->kexec_flags & KEXEC_ON_CRASH ) {
 		if (get_crash_memory_ranges(&mem_range, &nr_ranges) = 0) {
@@ -235,10 +235,16 @@ int load_crashdump_segments(struct kexec_info *info, struct mem_ehdr *ehdr,
 						       &tmp, &sz) < 0)
 				return -1;
 
-			elfcorehdr = add_buffer(info, tmp, sz, sz, EFI_PAGE_SIZE, min_base,
+			/* round sz up */
+			if (sz != ((sz >> EFI_PAGE_SHIFT) << EFI_PAGE_SHIFT))
+				memsz = ((sz >> EFI_PAGE_SHIFT) + 1) << EFI_PAGE_SHIFT;
+			else
+				memsz = sz;
+
+			elfcorehdr = add_buffer(info, tmp, sz, memsz, EFI_PAGE_SIZE, min_base,
 					max_addr, -1);
 			loaded_segments[loaded_segments_num].start = elfcorehdr;
-			loaded_segments[loaded_segments_num].end = elfcorehdr + size;
+			loaded_segments[loaded_segments_num].end = elfcorehdr + memsz;
 			loaded_segments[loaded_segments_num].reserved = 1;
 			loaded_segments_num++;
 			cmdline_add_elfcorehdr(cmdline, elfcorehdr);
diff --git a/kexec/arch/ia64/kexec-ia64.h b/kexec/arch/ia64/kexec-ia64.h
index 176d5f9..28a728b 100644
--- a/kexec/arch/ia64/kexec-ia64.h
+++ b/kexec/arch/ia64/kexec-ia64.h
@@ -10,6 +10,10 @@ int update_loaded_segments(struct kexec_info *info, struct mem_ehdr *ehdr);
 void move_loaded_segments(struct kexec_info *info, struct mem_ehdr *ehdr,
 			  unsigned long addr);
 
-#define EFI_PAGE_SIZE	  (1UL<<12)
+#define EFI_PAGE_SHIFT		12
+
+#define EFI_PAGE_SIZE	  (1UL<<EFI_PAGE_SHIFT)
 #define ELF_PAGE_SIZE	  (1UL<<16)
+
+
 #endif /* KEXEC_IA64_H */
