From: "David N. Lombard" <david.lombard@mscsoftware.com>
Date: Tue, 23 Jul 2002 23:58:30 +0000
Subject: [Linux-ia64] [PATCH] arch/ia64/tools/Makefile
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------070208050407070405000503"
Message-Id: <marc-linux-ia64-105590701905826@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------070208050407070405000503
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

The arch/ia64/tools/Makefile has an empty action for the mrproper 
target.  The result is that arch/ia64/tools/print_offsets.s, 
arch/ia64/tools/print_offsets, and arch/ia64/tools/offsets.h remain 
after a "make mrproper".  The files are deleted with "make distclean".

So, this could be a (subtle) intended difference between the mrproper 
and distclean targets, but that seems unlikely.

The attached patch moves the file deletion from the clean target 
(invoked via distclean) to the mrproper target; the distclean target 
still results in the files being deleted.

-- 
David N. Lombard
MSC.Software

--------------070208050407070405000503
Content-Type: text/plain;
 name="ia64-tools.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ia64-tools.diff"

--- arch/ia64/tools/Makefile.orig	Mon Feb 25 11:37:53 2002
+++ arch/ia64/tools/Makefile	Tue Jul 23 11:27:50 2002
@@ -5,6 +5,7 @@
 all: 
 
 mrproper:
+	rm -f print_offsets.s print_offsets offsets.h
 
 clean:
 	rm -f print_offsets.s print_offsets offsets.h

--------------070208050407070405000503--


