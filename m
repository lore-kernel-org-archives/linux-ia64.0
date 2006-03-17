From: "H. J. Lu" <hjl@lucon.org>
Date: Fri, 17 Mar 2006 21:46:57 +0000
Subject: Re: PATCH: Fix gnu-efi-3.0b-041222 for ia32
Message-Id: <20060317214657.GA21369@lucon.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060317202301.GA20807@lucon.org>
In-Reply-To: <20060317202301.GA20807@lucon.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Mar 17, 2006 at 12:53:24PM -0800, James E Wilson wrote:
> On Fri, 2006-03-17 at 12:45, James E Wilson wrote:
> > That should be .text.*, not .text*.
> 
> And because .text.* doesn't match .text, this actually needs to be
>     *(.text .text.*)

I don't think so. linker calls fnmatch to match section names by
patterns.  According to my man page:

NAME
       fnmatch - match filename or pathname

SYNOPSIS
       #include <fnmatch.h>

       int fnmatch(const char *pattern, const char *string, int flags);

DESCRIPTION
       The  fnmatch()  function checks whether the string argument
matches the
       pattern argument, which is a shell wildcard pattern.

".text*" should work as a shell wildcard pattern.

> Try looking at ld --verbose output, and grepping for .text.

This is the updated patch to include *(.gnu.linkonce.t.*) sections.



H.J.
---
--- gnu-efi/gnuefi/elf_ia32_efi.lds.ia32	2004-12-22 07:52:28.000000000 -0800
+++ gnu-efi/gnuefi/elf_ia32_efi.lds	2006-03-17 13:30:58.000000000 -0800
@@ -9,7 +9,12 @@ SECTIONS
   . = ALIGN(4096);
   .text :
   {
-   *(.text)
+   *(.text*)
+   *(.gnu.linkonce.t.*)
+  }
+  .reloc :
+  {
+   *(.reloc)
   }
   . = ALIGN(4096);
   .data :
@@ -48,12 +53,9 @@ SECTIONS
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
+++ gnu-efi/gnuefi/elf_ia64_efi.lds	2006-03-17 13:31:11.000000000 -0800
@@ -9,7 +9,7 @@ SECTIONS
   . = ALIGN(4096);
   .text :
   {
-   *(.text)
+   *(.text*)
    *(.gnu.linkonce.t*)
   }
   . = ALIGN(4096);
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
