From: "David N. Lombard" <david.lombard@mscsoftware.com>
Date: Tue, 23 Jul 2002 23:51:11 +0000
Subject: [Linux-ia64] [PATCH] arch/ia64/boot/Makefile
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------080701010408000000000208"
Message-Id: <marc-linux-ia64-105590701905825@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------080701010408000000000208
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

arch/ia64/boot/Makefile uses the macro TARGET without defining it.

The attached patch corrects that.

-- 
David N. Lombard
MSC.Software

--------------080701010408000000000208
Content-Type: text/plain;
 name="ia64-boot.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ia64-boot.diff"

--- arch/ia64/boot/Makefile.orig	Thu Jan  4 12:50:17 2001
+++ arch/ia64/boot/Makefile	Tue Jul 23 14:30:07 2002
@@ -27,6 +27,6 @@
 	-o bootloader
 
 clean:
-	rm -f $(TARGETS)
+	rm -f bootloader $(OBJECTS)
 
 dep:

--------------080701010408000000000208--


