From: Jay Lan <jlan@sgi.com>
Date: Wed, 15 Nov 2006 21:22:55 +0000
Subject: [PATCH] kexec-tools: bug fix to --noio option
Message-Id: <455B852F.4050502@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------080101070300060805040104"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------080101070300060805040104
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

This patch is to fix a "--noio option" patch posted on 9/20/2006 by
Nanhai that disables I/O in purgatory code.

The "--noio" option should specify zero argument to avoid eating out
the next option.


Signed-off-by: Jay Lan <jlan@sgi.com>


--------------080101070300060805040104
Content-Type: text/plain;
 name="noio-fix"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="noio-fix"

Index: kexec-tools-1.101/kexec/arch/ia64/kexec-elf-ia64.c
===================================================================
--- kexec-tools-1.101.orig/kexec/arch/ia64/kexec-elf-ia64.c	2006-11-15 13:05:25.000000000 -0800
+++ kexec-tools-1.101/kexec/arch/ia64/kexec-elf-ia64.c	2006-11-15 13:06:23.941960199 -0800
@@ -128,7 +128,7 @@ int elf_ia64_load(int argc, char **argv,
 		{"command-line", 1, 0, OPT_APPEND},
 		{"append",       1, 0, OPT_APPEND},
 		{"initrd",       1, 0, OPT_RAMDISK},
-		{"noio",       1, 0, OPT_NOIO},
+		{"noio",         0, 0, OPT_NOIO},
 		{0, 0, 0, 0},
 	};
 

--------------080101070300060805040104--
