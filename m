From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 03 Nov 2004 17:24:43 +0000
Subject: [PATCH] fix HPET time_interpolator registration
Message-Id: <200411031024.43782.bjorn.helgaas@hp.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_bRRiBY05LlZEtwr"
List-Id: <linux-ia64.vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Bob Picco <Robert.Picco@hp.com>, Venkatesh Pallipadi <venkatesh.pallipadi@intel.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Christoph Lameter <clameter@sgi.com>

--Boundary-00=_bRRiBY05LlZEtwr
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Fixup after mid-air collision between Christoph adding time_interpolator.mask,
and me removing a static time_interpolator struct from hpet.c.  This causes
a boot-time BUG() on boxes that use the hpet driver.

--Boundary-00=_bRRiBY05LlZEtwr
Content-Type: text/x-diff;
  charset="us-ascii";
  name="hpet-mask.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="hpet-mask.patch"

Fixup after mid-air collision between Christoph adding time_interpolator.mask,
and me removing a static time_interpolator struct from hpet.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

===== drivers/char/hpet.c 1.14 vs edited =====
--- 1.14/drivers/char/hpet.c	2004-11-02 07:40:42 -07:00
+++ edited/drivers/char/hpet.c	2004-11-03 10:05:26 -07:00
@@ -712,6 +712,7 @@
 	ti->addr = &hpetp->hp_hpet->hpet_mc;
 	ti->frequency = hpet_time_div(hpets->hp_period);
 	ti->drift = ti->frequency * HPET_DRIFT / 1000000;
+	ti->mask = 0xffffffffffffffffLL;
 
 	hpetp->hp_interpolator = ti;
 	register_time_interpolator(ti);

--Boundary-00=_bRRiBY05LlZEtwr--
