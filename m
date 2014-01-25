From: Mikael Pettersson <mikpelinux@gmail.com>
Date: Sat, 25 Jan 2014 18:09:30 +0000
Subject: [PATCH] ia64 hpsim: bump RAM size to 2GB
Message-Id: <21219.64986.555547.308322@gargle.gargle.HOWL>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

When the ia64 kernel runs on ski it only gets 130MB of RAM,
which is too little for many workloads.  Bump it to 2GB.
Tested with ski-1.3.2 on x86_64.

Signed-off-by: Mikael Pettersson <mikpelinux@gmail.com>
---
Maybe this should be runtime configurable, via something like
"ski bootloader --mem=2G vmlinux ...", but that would require
reworking the bootloader's command line parsing code.

diff -rupN linux-3.13/arch/ia64/hp/sim/boot/fw-emu.c linux-3.13.ia64-hpsim-2GB-RAM/arch/ia64/hp/sim/boot/fw-emu.c
--- linux-3.13/arch/ia64/hp/sim/boot/fw-emu.c	2013-09-03 19:06:28.000000000 +0200
+++ linux-3.13.ia64-hpsim-2GB-RAM/arch/ia64/hp/sim/boot/fw-emu.c	2014-01-25 11:24:01.703718921 +0100
@@ -336,7 +336,7 @@ sys_fw_init (const char *args, int argle
 	/* simulate free memory at physical address zero */
 	MAKE_MD(EFI_BOOT_SERVICES_DATA,		EFI_MEMORY_WB,    0*MB,    1*MB);
 	MAKE_MD(EFI_PAL_CODE,			EFI_MEMORY_WB,    1*MB,    2*MB);
-	MAKE_MD(EFI_CONVENTIONAL_MEMORY,	EFI_MEMORY_WB,    2*MB,  130*MB);
+	MAKE_MD(EFI_CONVENTIONAL_MEMORY,	EFI_MEMORY_WB,    2*MB, 2048*MB);
 	MAKE_MD(EFI_CONVENTIONAL_MEMORY,	EFI_MEMORY_WB, 4096*MB, 4128*MB);
 #else
 	MAKE_MD( 4,		   0x9, 0x0000000000000000, 0x0000000000001000);
