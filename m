From: Jesse Barnes <jesse.barnes@intel.com>
Date: Mon, 09 May 2005 21:52:09 +0000
Subject: [PATCH] update sn2 maintainer
Message-Id: <200505091452.09834.jesse.barnes@intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_Ju9fC6Dt4a76rB5"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_Ju9fC6Dt4a76rB5
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Now that I'm no longer at SGI and don't have access to Altix equipment, 
it's time to pass on the job of patch monkey to someone else.  Greg 
Edwards has foolishly^Wkindly volunteered for the job, so here's a 
patch to update the MAINTAINERS file with the appropriate information.

Signed-off-by: Jesse Barnes <jesse.barnes@intel.com>

Jesse

--Boundary-00=_Ju9fC6Dt4a76rB5
Content-Type: text/x-diff;
  charset="us-ascii";
  name="sn2-maintainer-update.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="sn2-maintainer-update.patch"

diff -Naurp linux-2.6.12-rc4.orig/MAINTAINERS linux-2.6.12-rc4/MAINTAINERS
--- linux-2.6.12-rc4.orig/MAINTAINERS	2005-05-06 22:20:31.000000000 -0700
+++ linux-2.6.12-rc4/MAINTAINERS	2005-05-09 14:29:53.000000000 -0700
@@ -1023,8 +1023,8 @@ W:	http://www.ia64-linux.org/
 S:	Maintained
 
 SN-IA64 (Itanium) SUB-PLATFORM
-P:	Jesse Barnes
-M:	jbarnes@sgi.com
+P:	Greg Edwards
+M:	edwardsg@sgi.com
 L:	linux-altix@sgi.com
 L:	linux-ia64@vger.kernel.org
 W:	http://www.sgi.com/altix

--Boundary-00=_Ju9fC6Dt4a76rB5--
