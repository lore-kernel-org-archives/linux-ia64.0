From: Bill Nottingham <notting@redhat.com>
Date: Thu, 01 Jun 2000 21:50:32 +0000
Subject: Re: [Linux-ia64] initrd suport for ELI, kernel
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Nq2Wo0NMKNjxTN9z"
Message-Id: <marc-linux-ia64-105590678205114@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205112@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205112@msgid-missing>
To: linux-ia64@vger.kernel.org

--Nq2Wo0NMKNjxTN9z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Bill Nottingham (notting@redhat.com) said: 
> Here's some patches that add initrd support to ELI
> and the kernel. 

FYI, if you've got a recent toolchain, you need the
attached patch for gnu-efi for it to build correctly
(thanks David!).

Bill

--Nq2Wo0NMKNjxTN9z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="gnu-efi.patch"

2000-04-03  David Mosberger  <davidm@hpl.hp.com>

	* gnuefi/elf_ia64_efi.lds: Include .IA_64.unwind and
	.IA_64.unwind_info in .data segment to avoid EFI load error
	"ImageAddress: pointer outside of image" error due to the .dynsym
	relocations against these sections.

	* gnuefi/reloc_ia64.S: fixed typo: .space directive had constant
	100 hardcoded instead of using MAX_FUNCTION_DESCRIPTORS
	macro. Duh.

diff -urN gnu-efi-0.8/gnuefi/elf_ia64_efi.lds gnu-efi-pre0.9/gnuefi/elf_ia64_efi.lds
--- gnu-efi-0.8/gnuefi/elf_ia64_efi.lds	Wed Sep 22 16:53:51 1999
+++ gnu-efi-pre0.9/gnuefi/elf_ia64_efi.lds	Mon Apr  3 17:35:29 2000
@@ -27,6 +27,8 @@
    *(.got.plt)
    *(.got)
    *(.plabel)	/* data whose relocs we want to ignore */
+   *(.IA_64.unwind)
+   *(.IA_64.unwind_info)
    /* the EFI loader doesn't seem to like a .bss section, so we stick
       it all into .data: */
    *(.sbss)
diff -urN gnu-efi-0.8/gnuefi/reloc_ia64.S gnu-efi-pre0.9/gnuefi/reloc_ia64.S
--- gnu-efi-0.8/gnuefi/reloc_ia64.S	Thu Sep 23 21:54:21 1999
+++ gnu-efi-pre0.9/gnuefi/reloc_ia64.S	Mon Apr  3 16:20:51 2000
@@ -204,5 +204,5 @@
 	.data
 	.align 16
 fptr_mem_base:
-	.space	100*16
+	.space  MAX_FUNCTION_DESCRIPTORS*16
 fptr_mem_limit:




--Nq2Wo0NMKNjxTN9z--


