From: Bill Nottingham <notting@redhat.com>
Date: Fri, 28 Sep 2001 19:01:12 +0000
Subject: [Linux-ia64] Re: kernel update (relative to 2.4.10)
MIME-Version: 1
Content-Type: multipart/mixed; boundary="YZ5djTAD1cGYuMQK"
Message-Id: <marc-linux-ia64-105590698805275@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205855@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205855@msgid-missing>
To: linux-ia64@vger.kernel.org

--YZ5djTAD1cGYuMQK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Bill Nottingham (notting@redhat.com) said: 
> FWIW, PCI r128 seemed to work fine, at least until the machine
> check. :(

Attached is a patch for PCI that fixes a definite oops in r128 and
presumably the same one in the radeon driver. Dunno if this was related
to the hard lockup/machine check I saw or not.

Bill

--YZ5djTAD1cGYuMQK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="linux-2.4.10-ia64-pcidrm.patch"

--- linux/drivers/char/drm/r128_cce.c.foo	Fri Sep 28 14:26:06 2001
+++ linux/drivers/char/drm/r128_cce.c	Fri Sep 28 14:26:17 2001
@@ -681,7 +681,7 @@
 		/*
 		 * Free the page we grabbed for RPTR_ADDR
 		 */
-		if( dev->agp->agp_info.chipset == INTEL_460GX ) {
+		if( !dev_priv->is_pci && dev->agp->agp_info.chipset == INTEL_460GX ) {
 			unsigned long alt_rh_off =
 				(unsigned long) dev_priv->ring.head;
 
--- linux-2.4.9-0.15/drivers/char/drm/radeon_cp.c.foo	Fri Sep 28 14:46:11 2001
+++ linux-2.4.9-0.15/drivers/char/drm/radeon_cp.c	Fri Sep 28 14:47:23 2001
@@ -1026,7 +1026,7 @@
 		/*
 		 * Free the page we grabbed for RPTR_ADDR
 		 */
-		if( dev->agp->agp_info.chipset == INTEL_460GX ) {
+		if( !dev_priv->is_pci && dev->agp->agp_info.chipset == INTEL_460GX ) {
 			unsigned long alt_rh_off =
 				(unsigned long) dev_priv->ring.head;
 

--YZ5djTAD1cGYuMQK--

