From: Uros Prestor <uros@turbolinux.com>
Date: Tue, 15 Aug 2000 23:43:39 +0000
Subject: [Linux-ia64] [PATCH] fix for modules_install
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------7FA6F08E0A8E062BE8927813"
Message-Id: <marc-linux-ia64-105590678205329@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------7FA6F08E0A8E062BE8927813
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

This trivial patch against 2.4.0-test6 + 000812 fixes a problem with
modules_install target.

Uros

--
Uros Prestor
uros@turbolinux.com



--------------7FA6F08E0A8E062BE8927813
Content-Type: text/plain; charset=us-ascii;
 name="linux-2.4.0-test6-ia64-modinstall.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.4.0-test6-ia64-modinstall.patch"

diff -ruN linux-2.4.0-test6-000811/arch/ia64/tools/Makefile linux-2.4.0-test6-000811.modules/arch/ia64/tools/Makefile
--- linux-2.4.0-test6-000811/arch/ia64/tools/Makefile	Fri Jul 14 16:08:12 2000
+++ linux-2.4.0-test6-000811.modules/arch/ia64/tools/Makefile	Tue Aug 15 15:53:02 2000
@@ -46,4 +46,4 @@
 
 endif
 
-.PHONY: all modules
+.PHONY: all modules modules_install

--------------7FA6F08E0A8E062BE8927813--


