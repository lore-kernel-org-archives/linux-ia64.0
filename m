From: Andreas Schwab <schwab@suse.de>
Date: Fri, 26 Sep 2003 18:54:16 +0000
Subject: Fix gnu-efi for gcc 3.3
Message-Id: <marc-linux-ia64-106460281214294@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

gcc 3.3 may generate sections named .data.rel and .data.rel.local, but the
linker script included in gnu-efi 3.0a didn't account for them.

--- gnu-efi-3.0a/gnuefi/elf_ia64_efi.lds
+++ gnu-efi-3.0a/gnuefi/elf_ia64_efi.lds
@@ -28,8 +28,7 @@
   {
    *(.rodata*)
    *(.ctors)
-   *(.data)
-   *(.data1)
+   *(.data*)
    *(.gnu.linkonce.d*)
    *(.plabel)	/* data whose relocs we want to ignore */
    *(.IA_64.unwind)
@@ -48,7 +47,7 @@
   .rela :
   {
     *(.rela.text)
-    *(.rela.data)
+    *(.rela.data*)
     *(.rela.sdata)
     *(.rela.got)
     *(.rela.gnu.linkonce.d*)

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
