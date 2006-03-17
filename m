From: "H. J. Lu" <hjl@lucon.org>
Date: Fri, 17 Mar 2006 20:23:01 +0000
Subject: PATCH: Fix gnu-efi-3.0b-041222 for ia32
Message-Id: <20060317202301.GA20807@lucon.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I don't know where I should report gnu-efi bug. The ia32 support in
gnu-efi-3.0b-041222 doesn't work with newer gcc and binutils. The
problem is in the linker script. The new gcc may put functions in
.text* sections. The newer linker handles orphaned sections
differently. I tested this patch on both ia32 and ia64 with different
versions of gcc and binutils by building elilo 3.6. Elilo 3.6 loads
and run kernel correctly on ia64. It seems to work find on ia32.

Thanks.


H.J.
--- gnu-efi/gnuefi/elf_ia32_efi.lds.ia32	2004-12-22 07:52:28.000000000 -0800
+++ gnu-efi/gnuefi/elf_ia32_efi.lds	2006-03-17 11:47:21.000000000 -0800
@@ -9,7 +9,11 @@ SECTIONS
   . = ALIGN(4096);
   .text :
   {
-   *(.text)
+   *(.text*)
+  }
+  .reloc :
+  {
+   *(.reloc)
   }
   . = ALIGN(4096);
   .data :
@@ -48,12 +52,9 @@ SECTIONS
   . = ALIGN(4096);
   .dynstr   : { *(.dynstr) }
   . = ALIGN(4096);
-  .ignored.reloc :
+  /DISCARD/ :
   {
     *(.rel.reloc)
-  }
-  .ignored :
-  {
     *(.eh_frame)
   }
 }
--- gnu-efi/gnuefi/elf_ia64_efi.lds.ia32	2004-12-22 10:18:10.000000000 -0800
+++ gnu-efi/gnuefi/elf_ia64_efi.lds	2006-03-17 11:51:51.000000000 -0800
@@ -59,13 +59,10 @@ SECTIONS
   .dynsym   : { *(.dynsym) }
   . = ALIGN(4096);
   .dynstr   : { *(.dynstr) }
-  .ignored_reloc :
+  /DISCARD/ :
   {
     *(.rela.plabel)
     *(.rela.reloc)
-  }
-  /DISCARD/ :
-  {
     *(.IA_64.unwind*)
     *(.IA64.unwind*)
   }
