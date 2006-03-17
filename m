From: "H. J. Lu" <hjl@lucon.org>
Date: Fri, 17 Mar 2006 23:31:18 +0000
Subject: Re: PATCH: Fix gnu-efi-3.0b-041222 for ia32
Message-Id: <20060317233118.GA22192@lucon.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060317202301.GA20807@lucon.org>
In-Reply-To: <20060317202301.GA20807@lucon.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Mar 17, 2006 at 03:15:48PM -0800, James E Wilson wrote:
> On Fri, 2006-03-17 at 13:52, H. J. Lu wrote:
> >     *(.gnu.linkonce.t*)
> 
> This isn't something you added, but should be fixed just the same.  This
> will accidentally cause some thread-local data sections to be merged
> into the text section.  The thread-local sections may not have existed
> when this code was written, but they do now.  .gnu.linkonce.td.* is used
> for linkonce thread local data, and .gnu.linkonce.tb.* is used for
> linkonce thread local bss.

I guess we never used TLS in EFI applications before. It doesn't
really matter since TLS needs more than the linker script change.
Here is the new patch.


H.J.
---
--- gnu-efi/gnuefi/elf_ia32_efi.lds.ia32	2004-12-22 07:52:28.000000000 -0800
+++ gnu-efi/gnuefi/elf_ia32_efi.lds	2006-03-17 13:48:13.000000000 -0800
@@ -10,6 +10,12 @@ SECTIONS
   .text :
   {
    *(.text)
+   *(.text.*)
+   *(.gnu.linkonce.t.*)
+  }
+  .reloc :
+  {
+   *(.reloc)
   }
   . = ALIGN(4096);
   .data :
@@ -48,12 +54,9 @@ SECTIONS
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
+++ gnu-efi/gnuefi/elf_ia64_efi.lds	2006-03-17 15:27:48.000000000 -0800
@@ -10,7 +10,8 @@ SECTIONS
   .text :
   {
    *(.text)
-   *(.gnu.linkonce.t*)
+   *(.text.*)
+   *(.gnu.linkonce.t.*)
   }
   . = ALIGN(4096);
   __gp = ALIGN (8) + 0x200000;
@@ -59,13 +60,10 @@ SECTIONS
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
