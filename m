From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Fri, 10 Sep 2004 22:14:54 +0000
Subject: [PATCH] sn2: fix warning in prominfo_proc.c
Message-Id: <200409101514.54621.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_ediQBuG0Lf6Eqzj"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_ediQBuG0Lf6Eqzj
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

The compiler has no way of knowing whether nentries will be greater than 0, so 
it was generating a warning that qw might be used uninitialized.  Fix it by 
explicitly setting it to 0.  Cc'ing Brian in case he has an internal version 
he'd like to keep in sync.

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse

--Boundary-00=_ediQBuG0Lf6Eqzj
Content-Type: text/plain;
  charset="us-ascii";
  name="prominfo-warning-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="prominfo-warning-fix.patch"

===== arch/ia64/sn/kernel/sn2/prominfo_proc.c 1.5 vs edited =====
--- 1.5/arch/ia64/sn/kernel/sn2/prominfo_proc.c	2004-08-25 10:27:31 -07:00
+++ edited/arch/ia64/sn/kernel/sn2/prominfo_proc.c	2004-09-10 15:09:28 -07:00
@@ -222,7 +222,7 @@
 {
 	int nentries;
 	int fentry;
-	unsigned long qw;
+	unsigned long qw = 0;
 	int len;
 	nasid_t nasid = NASID_GET(fit);
 

--Boundary-00=_ediQBuG0Lf6Eqzj--
