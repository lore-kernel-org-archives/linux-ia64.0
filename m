From: Andreas Schwab <schwab@suse.de>
Date: Thu, 05 Aug 2004 09:38:05 +0000
Subject: Fix use of acpi_register_irq
Message-Id: <jebrhqq60y.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

2.6.8-rc3 does not define acpi_register_irq, but <asm-ia64/acpi.h> still
declares  it and sound/drivers/mpu401/mpu401.c uses it.

Signed-off-by: Andreas Schwab <schwab@suse.de>

--- linux-2.6.8-rc3/include/asm-ia64/acpi.h.~1~	2004-06-16 07:19:52.0000000=
00 +0200
+++ linux-2.6.8-rc3/include/asm-ia64/acpi.h	2004-08-05 11:05:42.309209517 +=
0200
@@ -95,7 +95,6 @@ static inline void disable_acpi(void) {=20
=20
 const char *acpi_get_sysname (void);
 int acpi_request_vector (u32 int_type);
-int acpi_register_irq (u32 gsi, u32 polarity, u32 trigger);
 int acpi_gsi_to_irq (u32 gsi, unsigned int *irq);
=20
 #ifdef CONFIG_ACPI_NUMA
--- linux-2.6.8-rc3/sound/drivers/mpu401/mpu401.c.~1~	2004-08-05 11:29:36.2=
58858177 +0200
+++ linux-2.6.8-rc3/sound/drivers/mpu401/mpu401.c	2004-08-05 11:32:09.04513=
9404 +0200
@@ -30,6 +30,9 @@
 #ifdef CONFIG_ACPI_BUS
 #include <acpi/acpi_bus.h>
 #endif
+#ifdef CONFIG_IA64
+#include <linux/acpi.h>
+#endif
 #include <linux/moduleparam.h>
 #include <sound/core.h>
 #include <sound/mpu401.h>
@@ -99,9 +102,9 @@ static acpi_status __devinit snd_mpu401_
 	if (res->id =3D ACPI_RSTYPE_IRQ) {
 		if (res->data.irq.number_of_interrupts > 0) {
 #ifdef CONFIG_IA64
-			resources->irq =3D acpi_register_irq(res->data.irq.interrupts[0],
-							   res->data.irq.active_high_low,
-							   res->data.irq.edge_level);
+			resources->irq =3D acpi_register_gsi(res->data.irq.interrupts[0],
+							   res->data.irq.edge_level,
+							   res->data.irq.active_high_low);
 #else
 			resources->irq =3D res->data.irq.interrupts[0];
 #endif

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
