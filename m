From: Keith Owens <kaos@sgi.com>
Date: Mon, 04 Oct 2004 06:26:06 +0000
Subject: [patch 5/5 salinfo-0.6] version
Message-Id: <11391.1096871166@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

version         Bump the version to 0.6

Index: salinfo-0.6/Makefile
=================================--- salinfo-0.6.orig/Makefile	Mon Oct  4 12:41:29 2004
+++ salinfo-0.6/Makefile	Mon Oct  4 12:42:21 2004
@@ -1,4 +1,5 @@
-mandir		:= /usr/share/man
+# mandir has to be different because of rpmbuild
+mandir		:= $(prefix)/usr/share/man
 sbindir		:= /usr/sbin
 logdir		:= /var/log/salinfo
 initdir		:= /etc/rc.d/init.d
@@ -15,10 +16,10 @@ clean:
 
 install: salinfo_decode
 	chmod a+x salinfo_decode salinfo_decode_all salinfo-etc-init.d-salinfo_decode
-	mkdir -p $(prefix)$(mandir)/man8
+	mkdir -p $(mandir)/man8
 	mkdir -p $(prefix)$(logrotate) $(prefix)$(sbindir) $(prefix)$(initdir)
 	mkdir -p $(prefix)$(logdir) $(prefix)$(logdir)/raw $(prefix)$(logdir)/decoded
-	cp -a salinfo_decode.8 $(prefix)$(mandir)/man8
+	cp -a salinfo_decode.8 $(mandir)/man8
 	cp -a salinfo_decode salinfo_decode_all $(prefix)$(sbindir)
 	cp -a salinfo-etc-init.d-salinfo_decode $(prefix)$(initdir)/salinfo_decode
 	cp -a salinfo-logrotate.d-salinfo_decode $(prefix)$(logrotate)/salinfo_decode
Index: salinfo-0.6/salinfo.spec
=================================--- salinfo-0.6.orig/salinfo.spec	Mon Oct  4 12:41:29 2004
+++ salinfo-0.6/salinfo.spec	Mon Oct  4 12:41:32 2004
@@ -1,7 +1,7 @@
 Summary: Decode IA64 SAL records
 Name: salinfo
-Version: 0.4
-Release: 3
+Version: 0.6
+Release: 1
 Copyright: GPL
 Group: Utilities/System
 Source: salinfo-%{version}.tar.gz

