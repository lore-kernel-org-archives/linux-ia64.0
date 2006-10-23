From: Horms <horms@verge.net.au>
Date: Mon, 23 Oct 2006 08:48:43 +0000
Subject: [patch 3/5] Dont map PAL memory if physicall calls are going to be made
Message-Id: <20061023090334.467483535@tabatha.lab.ultramonkey.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

There seems to be no reason to map the PAL code into memory if
physical calls are going to be made.

Signed-Off-By: Simon Horman <horms@verge.net.au>

 arch/ia64/kernel/efi.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: kexec-ia64-2.6/arch/ia64/kernel/efi.c
=================================--- kexec-ia64-2.6.orig/arch/ia64/kernel/efi.c	2006-10-05 12:51:49.000000000 +0900
+++ kexec-ia64-2.6/arch/ia64/kernel/efi.c	2006-10-05 12:52:10.000000000 +0900
@@ -527,7 +528,6 @@
 	}
 #endif
 
-	efi_map_pal_code();
 	efi_enter_virtual_mode();
 }
 
@@ -601,6 +601,8 @@
 	efi.set_variable = virt_set_variable;
 	efi.get_next_high_mono_count = virt_get_next_high_mono_count;
 	efi.reset_system = virt_reset_system;
+
+	efi_map_pal_code();
 }
 
 /*

--

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

