From: Keith Owens <kaos@sgi.com>
Date: Mon, 04 Oct 2004 06:25:39 +0000
Subject: [patch 2/5 salinfo-0.6] logrotate
Message-Id: <11356.1096871139@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

logrotate       Use a better method of log rotation

Index: salinfo-0.6/Makefile
=================================--- salinfo-0.6.orig/Makefile	Mon Oct  4 12:26:56 2004
+++ salinfo-0.6/Makefile	Mon Oct  4 12:26:58 2004
@@ -1,8 +1,8 @@
-mandir	:= /usr/share/man
-crondir	:= /etc/cron.daily
-sbindir	:= /usr/sbin
-logdir	:= /var/log/salinfo
-initdir	:= /etc/rc.d/init.d
+mandir		:= /usr/share/man
+sbindir		:= /usr/sbin
+logdir		:= /var/log/salinfo
+initdir		:= /etc/rc.d/init.d
+logrotate	:= /etc/logrotate.d
 
 CFLAGS += -Wall -g $(EXTRA_CFLAGS)
 
@@ -14,10 +14,11 @@ clean:
 	rm -f salinfo_decode salinfo_decode_oem *.o
 
 install: salinfo_decode
+	chmod a+x salinfo_decode salinfo_decode_all salinfo-etc-init.d-salinfo_decode
 	mkdir -p $(prefix)$(mandir)/man8
-	mkdir -p $(prefix)$(crondir) $(prefix)$(sbindir) $(prefix)$(initdir)
+	mkdir -p $(prefix)$(logrotate) $(prefix)$(sbindir) $(prefix)$(initdir)
 	mkdir -p $(prefix)$(logdir) $(prefix)$(logdir)/raw $(prefix)$(logdir)/decoded
 	cp -a salinfo_decode.8 $(prefix)$(mandir)/man8
 	cp -a salinfo_decode salinfo_decode_all $(prefix)$(sbindir)
-	cp -a salinfo-cron-daily.d-salinfo_decode $(prefix)$(crondir)/salinfo_decode
 	cp -a salinfo-etc-init.d-salinfo_decode $(prefix)$(initdir)/salinfo_decode
+	cp -a salinfo-logrotate.d-salinfo_decode $(prefix)$(logrotate)/salinfo_decode
Index: salinfo-0.6/salinfo-cron-daily.d-salinfo_decode
=================================--- salinfo-0.6.orig/salinfo-cron-daily.d-salinfo_decode	Mon Oct  4 12:26:56 2004
+++ salinfo-0.6/salinfo-cron-daily.d-salinfo_decode	Thu Jan  1 10:00:00 1970
@@ -1,13 +0,0 @@
-#!/bin/bash
-
-# Files modified more than 21 days ago are deleted.  Files modified more than
-# 5 days ago are moved to the 'old' subdirectory so newer events are more
-# visible.
-
-dir=/var/log/salinfo
-find $dir -type f -mtime +21 | xargs -r rm -f
-for i in raw decoded
-do
-	mkdir -p $dir/$i/old
-	find $dir/$i -maxdepth 1 -type f -mtime +5 -exec mv {} $dir/$i/old \;
-done
Index: salinfo-0.6/salinfo-logrotate.d-salinfo_decode
=================================--- salinfo-0.6.orig/salinfo-logrotate.d-salinfo_decode	Thu Jan  1 10:00:00 1970
+++ salinfo-0.6/salinfo-logrotate.d-salinfo_decode	Mon Oct  4 12:26:58 2004
@@ -0,0 +1,15 @@
+/var/log/salinfo/decoded/* {
+    olddir /var/log/salinfo/decoded/old
+    maxage 21
+    weekly
+    notifempty
+    missingok
+}
+
+/var/log/salinfo/raw/* {
+    olddir /var/log/salinfo/raw/old
+    maxage 21
+    weekly
+    notifempty
+    missingok
+}
Index: salinfo-0.6/salinfo.spec
=================================--- salinfo-0.6.orig/salinfo.spec	Mon Oct  4 12:26:56 2004
+++ salinfo-0.6/salinfo.spec	Mon Oct  4 12:29:59 2004
@@ -36,7 +36,7 @@ rm -rf $RPM_BUILD_ROOT
 %attr(700,root,root) %dir	/var/log/salinfo/decoded
 %attr(755,root,root)		/usr/sbin/salinfo_decode
 %attr(755,root,root)		/usr/sbin/salinfo_decode_all
-%attr(755,root,root) %config	/etc/cron.daily/salinfo_decode
+%attr(644,root,root) %config	/etc/logrotate.d/salinfo_decode
 %attr(755,root,root) %config	/etc/rc.d/init.d/salinfo_decode
 %attr(644,root,root)		%{_mandir}/man8/salinfo_decode.8*
 


