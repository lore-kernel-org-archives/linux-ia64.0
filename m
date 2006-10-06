From: Horms <horms@verge.net.au>
Date: Fri, 06 Oct 2006 02:07:44 +0000
Subject: [patch 4/5] Choose physical or virtual SAL calls as appropriate
Message-Id: <20061006023253.031582000@tabatha.lab.ultramonkey.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The key thing about this patch is that it will make physical
SAL calls when physical EFI calls are being made (that is the
EFI code hasn't been mapped), and virtual calls otherwise.

The implientation is somewhat simple, but obviously there are many
ways to solve this problem. I am more than happy to change things
around on request.

Signed-Off-By: Simon Horman <horma@verge.net.au>
Index: kexec-ia64-2.6/include/linux/efi.h
=================================--- kexec-ia64-2.6.orig/include/linux/efi.h	2006-10-05 14:53:30.000000000 +0900
+++ kexec-ia64-2.6/include/linux/efi.h	2006-10-05 14:53:33.000000000 +0900
@@ -265,6 +265,7 @@
 	efi_get_next_high_mono_count_t *get_next_high_mono_count;
 	efi_reset_system_t *reset_system;
 	efi_set_virtual_address_map_t *set_virtual_address_map;
+	unsigned mapped;
 } efi;
 
 static inline int
Index: kexec-ia64-2.6/arch/ia64/kernel/efi.c
=================================--- kexec-ia64-2.6.orig/arch/ia64/kernel/efi.c	2006-10-05 14:53:30.000000000 +0900
+++ kexec-ia64-2.6/arch/ia64/kernel/efi.c	2006-10-05 14:54:20.000000000 +0900
@@ -600,6 +600,7 @@
 	efi.set_variable = virt_set_variable;
 	efi.get_next_high_mono_count = virt_get_next_high_mono_count;
 	efi.reset_system = virt_reset_system;
+	efi.mapped = 1;
 
 	efi_map_pal_code();
 }
Index: kexec-ia64-2.6/include/asm-ia64/sal.h
=================================--- kexec-ia64-2.6.orig/include/asm-ia64/sal.h	2006-10-05 14:53:30.000000000 +0900
+++ kexec-ia64-2.6/include/asm-ia64/sal.h	2006-10-05 14:53:33.000000000 +0900
@@ -64,8 +64,10 @@
 /* SAL spec _requires_ eight args for each call. */
 struct ia64_sal_retval sal_call_phys(ia64_sal_handler ia64_sal, ...);
 
-#define __SAL_CALL(result,a0,a1,a2,a3,a4,a5,a6,a7)	\
-	result = sal_call_phys(ia64_sal,a0,a1,a2,a3,a4,a5,a6,a7);
+#define __SAL_CALL(result,a0,a1,a2,a3,a4,a5,a6,a7)			\
+	result = efi.mapped ? 						\
+		 (*ia64_sal)(a0,a1,a2,a3,a4,a5,a6,a7) :			\
+		 sal_call_phys(ia64_sal,a0,a1,a2,a3,a4,a5,a6,a7);
 
 # define SAL_CALL(result,args...) do {				\
 	unsigned long __ia64_sc_flags;				\

--

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

