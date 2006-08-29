From: Kyle McMartin <kyle@debian.org>
Date: Tue, 29 Aug 2006 16:02:53 +0000
Subject: Fwd: Unable to compile 2.6.17.11 IA64 kernel
Message-Id: <20060829160253.GB19766@athena.road.mcmartin.ca>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Christian,

I've CC-ed your patch to the stable kernel maintainers. Hopefully
it will get merged for the next stable release.

Cheers,
	Kyle M.

----- Forwarded message from Christian Cotte-Barrot <Christian.Cotte-Barrot@bull.net> -----

Sender: linux-ia64-owner@vger.kernel.org
From: Christian Cotte-Barrot <Christian.Cotte-Barrot@bull.net>
Subject: Unable to compile 2.6.17.11 IA64 kernel
Message-ID: <44EEF7AC.5090804@bull.net>
To: linux-ia64 <linux-ia64@vger.kernel.org>
Date:	Fri, 25 Aug 2006 15:14:20 +0200

include/asm/mman.h: Assembler messages:
include/asm/mman.h:13: Error: Unknown opcode `int ia64_map_check_rgn(unsigned long addr,unsigned
long len,'
include/asm/mman.h:14: Error: Unknown opcode `unsigned long flags)'
make[1]: *** [arch/ia64/kernel/entry.o] Error 1
make: *** [arch/ia64/kernel] Error 2

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

----- End forwarded message -----
