From: Xavier Bru <xavier.bru@bull.net>
Date: Wed, 01 Sep 2004 10:25:43 +0000
Subject: HCDP concerns
Message-Id: <4135A3A7.9000706@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hello Bjorn and all,

I have some concerns with using kernel 2.6.8.1 (and 2.6.7) with our=20
platform that has a new BIOS that provides HCDP.

1) When kernel is configured without h/pcdp support ( CONFIG_EFI_PCDP is=20
not set),
the serial console are not initialized (efi.hcdp is not NULL).

A simple fix could be:
--- linux-2.6.8.1-ori/arch/ia64/kernel/setup.c    2004-08-14=20
12:54:50.000000000 +0200
+++ linux-2.6.8.1/arch/ia64/kernel/setup.c    2004-08-31=20
11:54:02.000000000 +0200
@@ -351,9 +351,9 @@
 #endif
 #ifdef CONFIG_EFI_PCDP
     efi_setup_pcdp_console(*cmdline_p);
+    if (!efi.hcdp)
 #endif
 #ifdef CONFIG_SERIAL_8250_CONSOLE
-    if (!efi.hcdp)
         setup_serial_legacy();
 #endif

2) Our platform has 2 serial ports (let say port 0 at address 3f8, port=20
1 at address 2f8). Usually port 0 is seen as ttyS0 & port 1 as ttyS1.=20
EFI console redirection is done on port S1 (2f8) & is described through=20
HCDP(port 0 is not described).
Using the h/pcdp support ( CONFIG_EFI_PCDP=3D1), we get some strange=20
behaviours:
. "console=3DttyS0" boot parameter, as explained in menuconfig takes the=20
HCDP table entry as console, but changes the ttyS* order:
ttyS1 for port 0 (3f8) and ttyS0 for port 1 (2f8). Console is OK,  but=20
the ttyS0 on port 1 is confusing compared to kernels without hcdp support.
. due to this behaviour, there is no more possibility to have the linux=20
console redirection on the port 0 at boot time.
. My understanding was that h/pcdp support should provide some new=20
console=EFi (or serial)  option to have the console defined by efi used=20
by linux as console, but that this should not change the ttyS order, and=20
that we should still be able to use console=3D"ttySx" at boot time to have =

the console on port "x".
. specifying no "console=3D" provides no console as the Conout variable is =

not exported by EFI at runtime. Should it be ?

Thanks in advance for your clarifications.
Xavier
--=20

 Sinc=E8res salutations.
_____________________________________________________________________
=20
Xavier BRU                 BULL ISD/R&D/INTEL office:     FREC B1-422
tel : +33 (0)4 76 29 77 45                    http://www-frec.bull.fr
fax : +33 (0)4 76 29 77 70                 mailto:Xavier.Bru@bull.net
addr: BULL, 1 rue de Provence, BP 208, 38432 Echirolles Cedex, FRANCE
_____________________________________________________________________

