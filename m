From: Fernando Vazquez <fernando@oss.ntt.co.jp>
Date: Fri, 25 Aug 2006 08:13:07 +0000
Subject: [PATCH] Linux 2.6.17.11 - fix compilation error on IA64 (try #3)
Message-Id: <1156493587.2977.20.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: gregkh@suse.de
Cc: dev@openvz.org, xemul@openvz.org, davem@davemloft.net, linux-kernel@vger.kernel.org, stable@kernel.org, akpm@osdl.org, linux-ia64@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com

Resending without Japanese characters in the mail header to avoid spam filters.
Sorry for the noise.

---

The commit 8833ebaa3f4325820fe3338ccf6fae04f6669254 introduced a change that broke 
IA64 compilation as shown below:

  gcc -Wp,-MD,arch/ia64/kernel/.entry.o.d  -nostdinc -isystem /usr/lib/gcc/ia64-linux-gnu/4.1.2/include -D__KERNEL__ -Iinclude  -include include/linux/autoconf.h -DHAVE_WORKING_TEXT_ALIGN -DHAVE_MODEL_SMALL_ATTRIBUTE -DHAVE_SERIALIZE_DIRECTIVE -D__ASSEMBLY__   -mconstant-gp -c -o arch/ia64/kernel/entry.o arch/ia64/kernel/entry.S
include/asm/mman.h: Assembler messages:
include/asm/mman.h:13: Error: Unknown opcode `int ia64_map_check_rgn(unsigned long addr,unsigned long len,'
include/asm/mman.h:14: Error: Unknown opcode `unsigned long flags)'
make[1]: *** [arch/ia64/kernel/entry.o] Error 1
make: *** [arch/ia64/kernel] Error 2

The reason is that "asm/mman.h" is being included from entry.S indirectly through
"asm/pgtable.h" (see code snips below).

* arch/ia64/kernel/entry.S:
...
#include <asm/pgtable.h>
...

* include/asm-ia64/pgtable.h:
...
#include <asm/mman.h>
...

* include/asm-ia64/mman.h
...
#ifdef __KERNEL__
#define arch_mmap_check ia64_map_check_rgn
int ia64_map_check_rgn(unsigned long addr, unsigned long len,
                unsigned long flags);
#endif
...

Signed-off-by: Fernando Vazquez <fernando@intellilink.co.jp>
---

diff -urNp linux-2.6.17.11/include/asm-ia64/mman.h linux-2.6.17.11-fix/include/asm-ia64/mman.h
--- linux-2.6.17.11/include/asm-ia64/mman.h	2006-08-25 11:36:09.000000000 +0900
+++ linux-2.6.17.11-fix/include/asm-ia64/mman.h	2006-08-25 11:39:16.000000000 +0900
@@ -9,10 +9,12 @@
  */
 
 #ifdef __KERNEL__
+#ifndef __ASSEMBLY__
 #define arch_mmap_check	ia64_map_check_rgn
 int ia64_map_check_rgn(unsigned long addr, unsigned long len,
 		unsigned long flags);
 #endif
+#endif
 
 #include <asm-generic/mman.h>
 


