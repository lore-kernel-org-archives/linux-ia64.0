From: Luming Yu <luming.yu@gmail.com>
Date: Thu, 20 Dec 2007 14:20:53 +0000
Subject: [RFC PATCH] clean up use of ia64 tool chain check scripts --resent
Message-Id: <20071220142053.GE4217@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello list,

ia64 seems to be the only one that use arch specific scripts to check
tool chain bugs that create the dependency on ia64 cross tool chain
that make the command : make ARCH=ia64 olconfig failed if ia64 cross
tool chain is __not__ installed or OBJDUMP and CC is __not__ set with
correct path on a non-ia64 box. Given the current state of art of
the tool chain, I don't know if these checks are still useful.
Please consider the following patch.

Thanks,
Luming

clean up use of ia64 tool chain check scripts

signed-off-by: Yu Luming <luming.yu@intel.com>

--
 Makefile |   11 +----------
 1 file changed, 1 insertion(+), 10 deletions(-)


--- linux-2.6.18.ia64/arch/ia64/Makefile.orig	2007-12-20 13:07:17.000000000 +0800
+++ linux-2.6.18.ia64/arch/ia64/Makefile	2007-12-20 13:01:50.000000000 +0800
@@ -28,16 +28,7 @@
 		   -falign-functions2 -frename-registers -fno-optimize-sibling-calls
 CFLAGS_KERNEL	:= -mconstant-gp
 
-GAS_STATUS	= $(shell $(srctree)/arch/ia64/scripts/check-gas "$(CC)" "$(OBJDUMP)")
-CPPFLAGS += $(shell $(srctree)/arch/ia64/scripts/toolchain-flags "$(CC)" "$(OBJDUMP)" "$(READELF)")
-
-ifeq ($(GAS_STATUS),buggy)
-$(error Sorry, you need a newer version of the assember, one that is built from	\
-	a source-tree that post-dates 18-Dec-2002.  You can find a pre-compiled	\
-	static binary of such an assembler at:					\
-										\
-		ftp://ftp.hpl.hp.com/pub/linux-ia64/gas-030124.tar.gz)
-endif
+CPPFLAGS += -DHAVE_WORKING_TEXT_ALIGN -DHAVE_MODEL_SMALL_ATTRIBUTE -DHAVE_SERIALIZE_DIRECTIVE
 
 ifeq ($(call cc-version),0304)
 	cflags-$(CONFIG_ITANIUM)	+= -mtune=merced
