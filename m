From: Horms <horms@verge.net.au>
Date: Mon, 05 Feb 2007 01:59:03 +0000
Subject: Zero size /proc/vmcore on ia64
Message-Id: <20070205015901.GA31446@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi, 

I have been poking around this problem a bit over the past week,
and I thought it would be a good idea to get it out in the open.

At some stage /proc/vmcore (in a crash-kernel) went from being
something useful, to being zero size. 

I initially thought this was because saved_max_pfn was not being 
set correctly. And indeed it is not set for discontig memory.
But the trivial fix below has not been sufficient to resolve the problem :(

The problem seems to be along the lines of:
  * kexec-tool sets up a segment to contain the elf header.
  * This segment happens to be almost at the end of the crashkernel area
    of memory that is visible to the crash kernel.
  * However, when purgatory munges the EFI map, this segment
    is marked as EFI_UNUSABLE_MEMORY.
  * As a result of this it is not in a range covered by efi_memmap_walk()
  * And thus it is outside the range of memory covered by a valid PFN
    (remember its at the end of memory, it turns out that the
     max PFN covers memory up until just before the header)
  * The header can't be read by the vmcore setup code
  * And vmcore is uninitialised

     read_from_oldmem: error: pfn (32761) > saved_max_pfn (31744)
     Kdump: vmcore not initialized

     The saved_max_pfn error above is produced by debuging code
     that I added to read_from_oldmem().
     It also uses the patch below, otherwise saved_max_pfn is 0.

For reference:
  I am using today's linus tree (2.6.20)
  The problem seems to have been around since at least 2.6.19-rc6
  I have a Tiger2 system using disctontig memory
  The problem also seems to manifest when using contig memory

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

Set saved_max_pfn when discontig memory is in use.

This sets up saved_max_pfn when disctontig memory is in use.
This mirrors the code for contig memory.

This patch does not entirely solve the problem of making vmcore work,
however it does appear to be neccessary. Please consider applying.

Signed-off-by: Simon Horman <horms@verge.net.au>

diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index 96722cb..999cefd 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -506,6 +509,12 @@ void __init find_memory(void)
 	max_pfn = max_low_pfn;
 
 	find_initrd();
+
+#ifdef CONFIG_CRASH_DUMP
+	/* If we are doing a crash dump, we still need to know the real mem
+	 * size before original memory map is reset. */
+        saved_max_pfn = max_pfn;
+#endif
 }
 
 #ifdef CONFIG_SMP
