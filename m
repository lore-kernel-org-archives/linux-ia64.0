From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 07 Jan 2002 17:09:11 +0000
Subject: [Linux-ia64] lm_sensors anyone?
Message-Id: <marc-linux-ia64-105590698805759@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Anyone interested in adding proper Itanium support to the lm_sensors
package?  The attached patch is a quick hack to demo that this package
can be made to work with the current Itanium machines, but I don't
really have time to finish this up.

If you're interested in this, here is some additional info: the SMBus
controller that is used to communicate with the sensors is documented
in the 460GX chipset documentation (see Chapter 14 in
http://developer.intel.com/design/itanium/downloads/24870321.htm).

As far as I know, this controller is very similar (perhaps identical)
to the SMBus controller in the PIIX4 chipset.  Running the
autodetection tool, the following sensors were detected:

	adm1021 adm1024 lm75 eeprom

The output from adm1021 looked reasonable.  Loading adm1024 increased
fan speed to maximum, so you may not want to do this (probably it's
possible to use it to control fan speed; I'm no expert for this).  The
lm75 output looked bogus (reporting 1 degree centigrade; not exactly
probable for a machine that sits in the Bay Area! ;-).

Does anyone have a complete list of what sensors are installed in the
Big Sur and Lions?

Oh, one caveat: I suspect it is possible to damage the machine with
improper use of the stuff hanging off the SMBus, so tread with care...

	--david

--- kernel/busses/i2c-piix4.c-orig	Sat Oct 13 10:48:43 2001
+++ kernel/busses/i2c-piix4.c	Wed Jan  2 22:08:21 2002
@@ -80,6 +80,7 @@
 
 static struct sd supported[] = {
 	{PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_82371AB_3, 3, "PIIX4"},
+	{PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_82372FB_3, 3, "460GX"},
 	{PCI_VENDOR_ID_SERVERWORKS, PCI_DEVICE_ID_SERVERWORKS_OSB4, 0, "OSB4"},
 	{PCI_VENDOR_ID_SERVERWORKS, PCI_DEVICE_ID_SERVERWORKS_CSB5, 0, "CSB5"},
 	{PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_82443MX_3, 3, "440MX"},
@@ -102,12 +103,21 @@
 #define SMBSLVDAT (0xC + piix4_smba)
 
 /* PCI Address Constants */
+#if 0
 #define SMBBA     0x090
 #define SMBHSTCFG 0x0D2
 #define SMBSLVC   0x0D3
 #define SMBSHDW1  0x0D4
 #define SMBSHDW2  0x0D5
 #define SMBREV    0x0D6
+#else
+#define SMBBA     0x020
+#define SMBHSTCFG 0x040
+#define SMBSLVC   0x041
+#define SMBSHDW1  0x042
+#define SMBSHDW2  0x043
+#define SMBREV    0x008
+#endif
 
 /* Other settings */
 #define MAX_TIMEOUT 500

