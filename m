From: Horms <horms@verge.net.au>
Date: Tue, 12 Dec 2006 09:06:13 +0000
Subject: [PATCH] [IA64] kexec/kdump: tidy up declaration of relocate_new_kernel_t
Message-Id: <20061212090611.GA9443@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

* Make NORET_TYPE and ATTRIB_NORET in line with the
  declaration for other architectures
* Add parameter names

Signed-Off-By: Simon Horman <horms@verge.net.au>

Index: kexec-ia64-2.6/arch/ia64/kernel/machine_kexec.c
=================================--- kexec-ia64-2.6.orig/arch/ia64/kernel/machine_kexec.c	2006-09-25 13:01:00.000000000 +0900
+++ kexec-ia64-2.6/arch/ia64/kernel/machine_kexec.c	2006-09-28 11:00:15.000000000 +0900
@@ -19,8 +19,11 @@
 #include <asm/delay.h>
 #include <asm/meminit.h>
 
-typedef void (*relocate_new_kernel_t)(unsigned long, unsigned long,
-		struct ia64_boot_param *, unsigned long);
+typedef NORET_TYPE void (*relocate_new_kernel_t)(
+					unsigned long indirection_page,
+					unsigned long start_address,
+					struct ia64_boot_param *boot_param,
+					unsigned long pal_addr) ATTRIB_NORET;
 
 struct kimage *ia64_kimage;
 
