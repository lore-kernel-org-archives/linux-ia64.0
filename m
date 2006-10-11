From: Terry Loftin <terry.loftin@hp.com>
Date: Wed, 11 Oct 2006 22:40:51 +0000
Subject: [PATCH] kexec-tools: ia64: icache flush should align to 32-bytes
Message-Id: <452D72F3.50107@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
I've run into problems testing kexec/kdump on a Montecito revision C
processor.  In purgatory, __dummy_efi_function is copied onto the
end of the command line boot parameter (command_line + command_line_len)
and this address is used to replace the EFI call to set_virtual_address_map().
The copied range is then icache flushed.

The destination address is aligned to 16-bytes (in kexec-elf-ia64.c), but
the fc.i instruction flushes a 32-byte range "associated" with that address.
When my command line length is 16-byte aligned but not 32-byte aligned, this
results in the first 16-bytes of __dummy_efi_function getting flushed (and
the 16 bytes prior to that), but the second half of the function (the part
with the br.ret) does not get flushed.  kdump then hangs in purgatory.  By
adding a few spaces to my command line, it becomes both 16 and 32-byte
aligned, and kdump works.


This patch makes icache_flush_range() align the start address to 32-bytes and
account for the difference.  The patch is against Horms kexec-tools-testing
tree.  As a side note, you could also fix this by just adding 32 to the length
passed to flush_icache_range() but that hides the dependent behavior.

Thanks,
-T

--- kexec-tools-testing/purgatory/arch/ia64/purgatory-ia64.c    2006-10-06 13:40:50.000000000 -0600
+++ kexec-tools-testing-new/purgatory/arch/ia64/purgatory-ia64.c        2006-10-11 16:05:06.000000000 -0600
@@ -222,7 +222,9 @@
  void
  flush_icache_range(char *start, unsigned long len)
  {
-	unsigned long i;
+	unsigned long i,addr;
+	addr = (unsigned long)start & ~31UL;
+	len += (unsigned long)start - addr;
  	for (i = 0;i < len; i += 32)
  	  asm volatile("fc.i %0"::"r"(start + i):"memory");
	asm volatile (";;sync.i;;":::"memory");

