From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Wed, 18 Apr 2001 19:24:25 +0000
Subject: [Linux-ia64] gnu-efi-2.0 initrd fix
MIME-Version: 1
Content-Type: multipart/mixed; boundary="qcHopEYAB45HaUaB"
Message-Id: <marc-linux-ia64-105590693005425@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--qcHopEYAB45HaUaB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi All,

I discovered that there was a bug with the code dealing with initrd in the new
elilo released as part of gnu-efi-2.0. The ramdisk would get freed by the kernel
right at initialization time before ever being used because the EFI memory
type used was wrong. The attached patch fixes the problem.

Please try it out and let me know how it goes.

Thanks.

-- 
-Stephane

--qcHopEYAB45HaUaB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="gnu-efi-2.0-initrd.diff"

diff -urN gnu-efi-2.0-old/elilo/alloc.c gnu-efi-2.0/elilo/alloc.c
--- gnu-efi-2.0-old/elilo/alloc.c	Wed Apr  4 22:20:33 2001
+++ gnu-efi-2.0/elilo/alloc.c	Wed Apr 18 12:16:57 2001
@@ -228,7 +228,7 @@
 alloc_initrd(EFI_PHYSICAL_ADDRESS start_addr, UINTN pgcnt)
 {
 
-	if (alloc_pages(pgcnt, EfiLoaderCode, AllocateAddress, start_addr) == 0) return -1;
+	if (alloc_pages(pgcnt, EfiRuntimeServicesCode, AllocateAddress, start_addr) == 0) return -1;
 
 	initrd_addr  = start_addr;
 	initrd_pgcnt = pgcnt;

--qcHopEYAB45HaUaB--

