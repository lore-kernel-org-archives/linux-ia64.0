From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Fri, 04 Jun 2004 22:51:25 +0000
Subject: [PATCH] ia64 MAINTAINERS update
Message-Id: <200406041551.25405.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_tzPwA9DosQhBL93"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, davidm@hpl.hp.com, akpm@osdl.org, willy@debian.org


--Boundary-00=_tzPwA9DosQhBL93
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Dave Hansen pointed out that linux-ia64@linuxia64.org is broken.  Since the 
list has moved and the domain is gone, update the list address and kill the 
URL.  I think willy has a new domain for ia64 Linux, but it was down for me, 
so I'll let him update the file later with the new URL if he wants to.

Jesse

--Boundary-00=_tzPwA9DosQhBL93
Content-Type: text/plain;
  charset="us-ascii";
  name="ia64-maintainers-update.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="ia64-maintainers-update.patch"

===== MAINTAINERS 1.216 vs edited =====
--- 1.216/MAINTAINERS	Mon May 31 18:02:57 2004
+++ edited/MAINTAINERS	Fri Jun  4 15:49:17 2004
@@ -944,15 +944,14 @@
 IA64 (Itanium) PLATFORM
 P:	David Mosberger-Tang
 M:	davidm@hpl.hp.com
-L:	linux-ia64@linuxia64.org
-W:	http://www.linuxia64.org/
+L:	linux-ia64@vger.kernel.org
 S:	Maintained
 
 SN-IA64 (Itanium) SUB-PLATFORM
 P:	Jesse Barnes
 M:	jbarnes@sgi.com
 L:	linux-altix@sgi.com
-L:	linux-ia64@linuxia64.org
+L:	linux-ia64@vger.kernel.org
 W:	http://www.sgi.com/altix
 S:	Maintained
 

--Boundary-00=_tzPwA9DosQhBL93--
