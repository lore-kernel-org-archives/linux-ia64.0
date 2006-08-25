From: Christian Cotte-Barrot <Christian.Cotte-Barrot@bull.net>
Date: Fri, 25 Aug 2006 13:14:20 +0000
Subject: Unable to compile 2.6.17.11 IA64 kernel
Message-Id: <44EEF7AC.5090804@bull.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------020209000304090003000404"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------020209000304090003000404
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii

include/asm/mman.h: Assembler messages:
include/asm/mman.h:13: Error: Unknown opcode `int ia64_map_check_rgn(unsigned long addr,unsigned
long len,'
include/asm/mman.h:14: Error: Unknown opcode `unsigned long flags)'
make[1]: *** [arch/ia64/kernel/entry.o] Error 1
make: *** [arch/ia64/kernel] Error 2

-- 
+===========+=======================+==================================+
|  |\/\/\/| |                       |                                  |
|  |      | |Christian Cotte-Barrot |org.  :BULL/                      |
|  | (~)(o) |Bull S.A.              |office:FREC/B1-401                |
| C      _) |1, rue de Provence     |mailto:                           |
|  | ,___|  |B.P. 208               |   Christian.Cotte-Barrot@bull.net|
|  |   /    |38432 ECHIROLLES CEDEX |phone :+33 (0)476297725 (229 7725)|
| /----\    |FRANCE                 |fax   :+33 (0)476297518 (229 7518)|
+===========+=======================+==================================+

--------------020209000304090003000404
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
 name="kernelorg-mman.h.patch"
Content-Disposition: inline;
 filename="kernelorg-mman.h.patch"

--- linux-2.6.17.11.ref/include/asm-ia64/mman.h	2006-08-23 23:16:33.000000000 +0200
+++ linux-2.6.17.11/include/asm-ia64/mman.h	2006-08-25 14:52:49.000000000 +0200
@@ -9,9 +9,11 @@
  */
 
 #ifdef __KERNEL__
+#if !defined(__ASSEMBLY__)
 #define arch_mmap_check	ia64_map_check_rgn
 int ia64_map_check_rgn(unsigned long addr, unsigned long len,
 		unsigned long flags);
+#endif /* !__ASSEMBLY__ */
 #endif
 
 #include <asm-generic/mman.h>

--------------020209000304090003000404--
