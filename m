From: Andreas Schwab <schwab@suse.de>
Date: Wed, 01 Sep 2004 09:10:17 +0000
Subject: 2.6.9-rc1: export pm_power_off
Message-Id: <jevfeywe12.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

The ipmi_poweroff module wants to access pm_power_off.

Signed-off-by: Andreas Schwab <schwab@suse.de>

--- linux-2.6.9-rc1/arch/ia64/kernel/acpi.c.~1~	2004-09-01 10:09:59.2611131=
81 +0200
+++ linux-2.6.9-rc1/arch/ia64/kernel/acpi.c	2004-09-01 10:12:36.587256773 +=
0200
@@ -61,6 +61,7 @@
 void (*pm_idle) (void);
 EXPORT_SYMBOL(pm_idle);
 void (*pm_power_off) (void);
+EXPORT_SYMBOL(pm_power_off);
=20
 unsigned char acpi_kbd_controller_present =3D 1;
 unsigned char acpi_legacy_devices;

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
