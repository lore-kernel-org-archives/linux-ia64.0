From: Michael Madore <mmadore@turbolinux.com>
Date: Thu, 06 Sep 2001 22:00:11 +0000
Subject: [Linux-ia64] small patch for ntfs driver
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------E81F1A662C3976892F00D20C"
Message-Id: <marc-linux-ia64-105590698805133@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------E81F1A662C3976892F00D20C
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi,

The ntfs driver compile is broken in 2.4.9 due to the min/max changes. 
Here is a patch if anyone is interested.

Mike Madore
Senior Software Engineer
TurboLinux, Inc.
650-228-5203
--------------E81F1A662C3976892F00D20C
Content-Type: text/plain; charset=us-ascii;
 name="kernel-2.4.9-ntfs_minmax.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="kernel-2.4.9-ntfs_minmax.patch"

diff -Nur linux/fs/ntfs/unistr.c linux.new/fs/ntfs/unistr.c
--- linux/fs/ntfs/unistr.c	Wed Aug 15 01:22:17 2001
+++ linux.new/fs/ntfs/unistr.c	Thu Sep  6 13:25:07 2001
@@ -22,6 +22,7 @@
  */
 
 #include <linux/string.h>
+#include <linux/kernel.h>
 #include <asm/byteorder.h>
 
 #include "unistr.h"

--------------E81F1A662C3976892F00D20C--


