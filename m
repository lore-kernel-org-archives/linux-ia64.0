From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 07 Aug 2008 21:41:11 +0000
Subject: RE: [RFC] Fix early access to per-cpu variables
Message-Id: <57C9024A16AD2D4C97DC78E552063EA308384543@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <57C9024A16AD2D4C97DC78E552063EA3083844C8@orsmsx505.amr.corp.intel.com>
In-Reply-To: <57C9024A16AD2D4C97DC78E552063EA3083844C8@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Robin,

> I manually fixed up the patch to put the tabs back

ooops ... thanks for applying a broken patch.

> applied it and
> boot tested it with generic_defconfig on a 128p 32 node NUMA system.
> How many other configs would you like tested?  Architecturally, this
> machine covers most of what SGI ships.

If that machine covers most of the bases ... then it should be
good enough.  Did you set CONFIG_PRINTK_TIME=3Dy?  I belatedly
looked back at the full console log for the system with this
patch in place and timestamps turned on ... and noticed that
the first few timestamps are garbage:

[3229294845.102478] Linux version 2.6.27-rc2-generic-smp (aegl@linux-t10.sc=
.intel.com) (gcc version 3.4.6 20060404 (Red Hat 3.4.6-8)) #2 SMP Thu Aug 7=
 13:48:58 PDT 2008
[3229324257.038521] SHA1=B20dc163e3e632efabd50694a5bcbf256f2c3c94
[3229357591.711361] EFI v1.10 by INTEL: SALsystab=3D0x7fe0cce0 ACPI=3D0x7ff=
0d000 ACPI 2.0=3D0x7ff0c000 MPS=3D0x7ff0b000 SMBIOS=3D0xf0000
[3236985012.679081] booting generic kernel on platform dig
[3237032692.542690] Early serial console at I/O port 0x2f8 (options '115200=
')
[3237065729.431131] console [uart0] enabled
[3347611298.502628] ACPI: RSDP 7FF0C000, 0024 (r2 INTEL )
[3359505546.140625] ACPI: XSDT 7FF0C090, 0034 (r1 INTEL  SR870BN4  1072002 =
MSFT    10013)
[3377823100.621728] ACPI: FACP 7FF0C138, 00F4 (r3 INTEL  SR870BN4  1072002 =
MSFT    10013)
[3396160520.758231] ACPI: DSDT 7FF0E000, 792B (r1  Intel SR870BN4        0 =
INTL 20030918)
[3414482553.458567] ACPI: FACS 7FF0C3A8, 0040
[3423961729.532777] ACPI: APIC 7FF0C230, 0176 (r1 INTEL  SR870BN4  1072002 =
MSFT    10013)
[    0.000000] Initial ramdisk at: 0xe0000001fedfa000 (1334080 bytes)
[    0.000000] SAL 3.20: Intel Corp                       SR870BN4         =
                version 3.0
[    0.000000] SAL Platform features: BusLock

Better than crashing ... but not as nice as it could be.

-Tony
