From: dann frazier <dannf@hp.com>
Date: Fri, 08 Apr 2005 21:23:43 +0000
Subject: [PATCH] salinfo_decode silent exit in older 2.4s
Message-Id: <1112995423.7189.133.camel@krebs.dannf>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-3SG2wgm+4BF0X6z7mI7R"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--=-3SG2wgm+4BF0X6z7mI7R
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

I was playing with salinfo_decode on an older kernel (2.4.21 era) and it
would normally die silently right after exec.

This no longer happens because of a semantic difference that occurred in
later 2.4 kernels.  Older 2.4s would return -EINTR when they wanted
userspace to try again, while current 2.4s use -ERESTARTSYS.  (The
surrounding code is also somewhat different, but it looks like the idea
is the same).

If salinfo_decode detects an EINTR, it will silently exit the main loop.
This patch corrects the problem for me on older kernels, and should have
no effect for current kernels.  Hopefully this is what the author
originally intended.

Signed-off-by: dann frazier <dannf@hp.com>

--- salinfo-0.7.orig/salinfo_decode.c	Tue Oct  5 09:23:33 2004
+++ salinfo-0.7/salinfo_decode.c	Fri Apr  8 15:06:40 2005
@@ -235,7 +235,7 @@
 		char filename[PATH_MAX];
 		if (read(fd_event, text, sizeof(text)) <= 0) {
 			if (errno == EINTR)
-				ret = 0;
+				continue;
 			else
 				perror(event_filename);
 			goto out;




--=-3SG2wgm+4BF0X6z7mI7R
Content-Disposition: attachment; filename=salinfo.patch
Content-Type: text/x-patch; name=salinfo.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit

--- salinfo-0.7.orig/salinfo_decode.c	Tue Oct  5 09:23:33 2004
+++ salinfo-0.7/salinfo_decode.c	Fri Apr  8 15:06:40 2005
@@ -235,7 +235,7 @@
 		char filename[PATH_MAX];
 		if (read(fd_event, text, sizeof(text)) <= 0) {
 			if (errno == EINTR)
-				ret = 0;
+				continue;
 			else
 				perror(event_filename);
 			goto out;

--=-3SG2wgm+4BF0X6z7mI7R--

