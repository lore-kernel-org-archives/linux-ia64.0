From: Wolfgang Mauerer <wolfgang@top.mynetix.de>
Date: Sun, 23 Mar 2003 19:11:25 +0000
Subject: [Linux-ia64] [TRIVIAL PATCH] Cross-compile fix
Message-Id: <marc-linux-ia64-105590723705294@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

the attached patch (against bk-current) fixes a cross 
compilation problem by using the target specific objdump 
tool instead of the host specific one.

Thanks, Wolfgang


--- a/arch/ia64/Makefile	Wed Mar  5 04:28:56 2003
+++ b/arch/ia64/Makefile	Sat Mar 22 15:38:15 2003
@@ -23,7 +23,7 @@
 
 GCC_VERSION=$(shell $(CC) -v 2>&1 | fgrep 'gcc version' | cut -f3 -d' ' | cut -f1 -d'.')
 
-GAS_STATUS=$(shell arch/ia64/scripts/check-gas $(CC))
+GAS_STATUS=$(shell arch/ia64/scripts/check-gas $(CC) $(OBJDUMP))
 
 ifeq ($(GAS_STATUS),buggy)
 $(error Sorry, you need a newer version of the assember, one that is built from	\

--- a/arch/ia64/scripts/check-gas	Wed Mar  5 04:29:33 2003
+++ b/arch/ia64/scripts/check-gas	Sat Mar 22 15:38:27 2003
@@ -1,8 +1,9 @@
 #!/bin/sh
 dir=$(dirname $0)
 CC=$1
+OBJDUMP=$2
 $CC -c $dir/check-gas-asm.S
-res=$(objdump -r --section .data check-gas-asm.o | fgrep 00004 | tr -s ' ' |cut -f3 -d' ')
+res=$($OBJDUMP -r --section .data check-gas-asm.o | fgrep 00004 | tr -s ' ' |cut -f3 -d' ')
 if [ $res != ".text" ]; then
 	echo buggy
 else



