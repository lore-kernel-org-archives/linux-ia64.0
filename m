From: Andreas Schwab <schwab@suse.de>
Date: Mon, 26 Aug 2002 11:40:40 +0000
Subject: [Linux-ia64] DRM compile fix
Message-Id: <marc-linux-ia64-105590701905979@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

The struct page does not have a wait queue any more.

--- linux/drivers/char/drm/r128_cce.c.~1~
+++ linux/drivers/char/drm/r128_cce.c
@@ -685,10 +685,10 @@ int r128_do_cleanup_cce( drm_device_t *d
 		if( !dev_priv->is_pci && dev->agp->agp_info.chipset =3D INTEL_460GX ) {
 			unsigned long alt_rh_off  				(unsigned long) dev_priv->ring.head;
+			struct page *p =3D virt_to_page((void *)alt_rh_off);
=20
-			atomic_dec(&virt_to_page(alt_rh_off)->count);
-			clear_bit(PG_locked, &virt_to_page(alt_rh_off)->flags);
-			wake_up(&virt_to_page(alt_rh_off)->wait);
+			put_page(p);
+			unlock_page(p);
 			free_page(alt_rh_off);
 		}
 #endif
--- linux/drivers/char/drm/radeon_cp.c.~1~
+++ linux/drivers/char/drm/radeon_cp.c
@@ -1028,10 +1028,10 @@ int radeon_do_cleanup_cp( drm_device_t *
 		if( !dev_priv->is_pci && dev->agp->agp_info.chipset =3D INTEL_460GX ) {
 			unsigned long alt_rh_off  				(unsigned long) dev_priv->ring.head;
+			struct page *p =3D virt_to_page((void *)alt_rh_off);
=20
-			atomic_dec(&virt_to_page(alt_rh_off)->count);
-			clear_bit(PG_locked, &virt_to_page(alt_rh_off)->flags);
-			wake_up(&virt_to_page(alt_rh_off)->wait);
+			put_page(p);
+			unlock_page(p);
 			free_page(alt_rh_off);
 		}
 #endif

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

