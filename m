From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Date: Tue, 20 Feb 2007 17:35:16 +0000
Subject: [PATCH 2.6.20-mm2] always build arch/ia64/lib/xor.o
Message-Id: <1171992916.5253.41.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Always build ia64 xor.o because multiple config options now 
depend on it.

Necessary to build .20-mm* on ia64 when, e.g., CONFIG_ASYNC_TX_DMA
is defined.  Don't know if '_ASYNC_TX_DMA makes sense on ia64.
If not, maybe Kconfig should preclude it.

Could have defined a Kconfig option that defaults to true
if MD_RAID456 || ASYNC_TX_DMA to control building of xor.o,
but xor.o is only 848 bytes and this IS ia64...

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 arch/ia64/lib/Makefile |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

Index: Linux/arch/ia64/lib/Makefile
=================================--- Linux.orig/arch/ia64/lib/Makefile	2007-02-04 13:44:54.000000000 -0500
+++ Linux/arch/ia64/lib/Makefile	2007-02-16 16:33:10.000000000 -0500
@@ -9,12 +9,11 @@ lib-y := __divsi3.o __udivsi3.o __modsi3
 	checksum.o clear_page.o csum_partial_copy.o			\
 	clear_user.o strncpy_from_user.o strlen_user.o strnlen_user.o	\
 	flush.o ip_fast_csum.o do_csum.o				\
-	memset.o strlen.o
+	memset.o strlen.o xor.o
 
 lib-$(CONFIG_ITANIUM)	+= copy_page.o copy_user.o memcpy.o
 lib-$(CONFIG_MCKINLEY)	+= copy_page_mck.o memcpy_mck.o
 lib-$(CONFIG_PERFMON)	+= carta_random.o
-lib-$(CONFIG_MD_RAID456)	+= xor.o
 
 AFLAGS___divdi3.o	 AFLAGS___udivdi3.o	= -DUNSIGNED


