From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Thu, 17 Apr 2003 02:53:24 +0000
Subject: [Linux-ia64] Cross compilation fix (2.5)
Message-Id: <marc-linux-ia64-105590723705529@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

To cross-compile Linux 2.5, you need this small patch,
otherwise the native objdump is used instead of one that understands
elf-ia64 images.

=== arch/ia64/scripts/check-gas 1.1 vs edited ==--- 1.1/arch/ia64/scripts/check-gas     Sat Jan 25 14:45:37 2003
+++ edited/arch/ia64/scripts/check-gas  Fri Apr 11 13:59:11 2003
@@ -2,7 +2,7 @@
 dir=$(dirname $0)
 CC=$1
 $CC -c $dir/check-gas-asm.S
-res=$(objdump -r --section .data check-gas-asm.o | fgrep 00004 | tr -s ' ' |cut -f3 -d' ')
+res=$(${CROSS_COMPILE}objdump -r --section .data check-gas-asm.o | fgrep 00004 | tr -s ' ' |cut -f3 -d' ')
 if [ $res != ".text" ]; then
	echo buggy
 else

