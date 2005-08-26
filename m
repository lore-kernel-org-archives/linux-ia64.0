From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 26 Aug 2005 21:56:45 +0000
Subject: Delete erroneous copy_page.o in global lib-y list
Message-Id: <200508262156.j7QLujg26042@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

copy_page.o appeared twice in arch/ia64/lib/Makefile. The
one in global lib-y is wrong where it should be just in
lib-$(CONFIG_ITANIUM).

Both copy_page.o and copy_page_mck.o are build for Itanium2
processor and the link order will pick up the low performing
copy_page function (originally written for itanium processor).
In this case, we really want the copy_page_mck.o for optimized
version.

Patch to delete the erroneous lib-y list.  Please apply, and
It would be nice to get this merged for 2.6.13.


Signed-off-by: Kenneth Chen <kenneth.w.chen@intel.com>

--- ./arch/ia64/lib/Makefile.orig	2005-08-26 14:45:58.070506150 -0700
+++ ./arch/ia64/lib/Makefile	2005-08-26 14:46:38.280466595 -0700
@@ -6,7 +6,7 @@ obj-y := io.o
 
 lib-y := __divsi3.o __udivsi3.o __modsi3.o __umodsi3.o			\
 	__divdi3.o __udivdi3.o __moddi3.o __umoddi3.o			\
-	bitop.o checksum.o clear_page.o csum_partial_copy.o copy_page.o	\
+	bitop.o checksum.o clear_page.o csum_partial_copy.o		\
 	clear_user.o strncpy_from_user.o strlen_user.o strnlen_user.o	\
 	flush.o ip_fast_csum.o do_csum.o				\
 	memset.o strlen.o swiotlb.o

