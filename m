From: Bernhard Walle <bwalle@suse.de>
Date: Mon, 12 Feb 2007 18:57:56 +0000
Subject: Re: [Fastboot] Zero size /proc/vmcore on ia64
Message-Id: <20070212185756.GA22524@strauss.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

* Zou, Nanhai <nanhai.zou@intel.com> [2007-02-09 00:45]:
>  I have not implement serial print in purgatory code yet, see
>  comments in purgatory/arch/ia64/console-ia64.c However from your
>  print, I can see last 2 entries of efi mem map are corrupt. 

I have the same problem (corrupted memory map entries), and the cause
was in kexec-tools, patch below. I'm not sure if the fix is right, at
least the problem is the uninitialised value of size. :)

Signed-off-by: Bernhard Walle <bwalle@suse.de>

---
 crashdump-ia64.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/kexec/arch/ia64/crashdump-ia64.c b/kexec/arch/ia64/crashdump-ia64.c
index 14e95a6..be61dc1 100644
--- a/kexec/arch/ia64/crashdump-ia64.c
+++ b/kexec/arch/ia64/crashdump-ia64.c
@@ -221,7 +221,7 @@ int load_crashdump_segments(struct kexec_info *info, struct mem_ehdr *ehdr,
 	struct memory_range *mem_range;
 	int nr_ranges;
 	unsigned long sz;
-	size_t size;
+	size_t size = 0;
 	void *tmp;
 	if (info->kexec_flags & KEXEC_ON_CRASH ) {
 		if (get_crash_memory_ranges(&mem_range, &nr_ranges) = 0) {
@@ -238,7 +238,7 @@ int load_crashdump_segments(struct kexec_info *info, struct mem_ehdr *ehdr,
 			elfcorehdr = add_buffer(info, tmp, sz, sz, EFI_PAGE_SIZE, min_base,
 					max_addr, -1);
 			loaded_segments[loaded_segments_num].start = elfcorehdr;
-			loaded_segments[loaded_segments_num].end = elfcorehdr + size;
+			loaded_segments[loaded_segments_num].end = elfcorehdr + sz;
 			loaded_segments[loaded_segments_num].reserved = 1;
 			loaded_segments_num++;
 			cmdline_add_elfcorehdr(cmdline, elfcorehdr);
