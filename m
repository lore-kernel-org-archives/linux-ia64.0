From: =?ISO-8859-1?Q?=C9meric_Maschino?= <emeric.maschino@gmail.com>
Date: Tue, 12 Apr 2011 19:49:34 +0000
Subject: [PATCH?] [TTM] AGP Bind memory failed.
Message-Id: <BANLkTi=wKR=Oi3GGf8uRf07LJjKtpX6Tzw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi,

Debian "Wheezy" Testing has just switched to kernel 2.6.38. I was thus
hoping that kernel 2.6.38 fixed the issue I experienced nearly one
year ago with DRI not being enabled with kernel 2.6.32~34, thus
disabling GPU acceleration and reverting AGP mode to PCI
(http://marc.info/?l=3Dlinux-ia64&m=127713282815600&w=3D2). Unfortunately
not, dmesg is still stating that AGP bind memory fails, GPU
acceleration is disabled and AGP mode is forced to PCI:

<snip>

[   28.133593] [drm] Initialized drm 1.1.0 20060810
[   28.140417] Linux video capture interface: v2.00
[   28.298800] GSI 38 (level, low) -> CPU 1 (0x0100) vector 60
[   28.298839] FM801 0000:40:01.0: PCI INT A -> GSI 38 (level, low) -> IRQ =
60
[   28.719916] [drm] radeon defaulting to kernel modesetting.
[   28.719958] [drm] radeon kernel modesetting enabled.
[   28.720255] GSI 60 (level, low) -> CPU 0 (0x0000) vector 61
[   28.720292] radeon 0000:80:00.0: PCI INT A -> GSI 60 (level, low) -> IRQ=
 61
[   28.723258] [drm] initializing kernel modesetting (R300 0x1002:0x4E47).
[   28.723301] [drm] register mmio base: 0xD8030000
[   28.723333] [drm] register mmio size: 65536
[   28.726843] radeon 0000:80:00.0: putting AGP V2 device into 2x mode
[   28.727161] radeon 0000:80:00.0: GTT: 512M 0x60000000 - 0x7FFFFFFF
[   28.727253] [drm] Generation 1 PCI interface in multifunction mode
[   28.727288] [drm] Limiting VRAM to one aperture
[   28.727325] radeon 0000:80:00.0: VRAM: 256M 0x00000000D0000000 - 0x00000=
000DF
FFFFFF (256M used)
[   28.727383] [drm] Supports vblank timestamp caching Rev 1 (10.10.2010).
[   28.727418] [drm] Driver supports precise vblank timestamp query.
[   28.727480] [drm] radeon: irq initialized.
[   28.727513] [drm] Detected VRAM RAM%6M, BAR=128M
[   28.727546] [drm] RAM width 256bits DDR
[   28.727657] [TTM] Zone  kernel: Available graphics memory: 3110864 kiB.
[   28.727693] [TTM] Zone   dma32: Available graphics memory: 2097152 kiB.
[   28.727729] [TTM] Initializing pool allocator.
[   28.727796] [drm] radeon: 256M of VRAM memory ready
[   28.727830] [drm] radeon: 512M of GTT memory ready.
[   28.727902] [drm] radeon: 2 quad pipes, 1 Z pipes initialized.
[   28.728835] [TTM] AGP Bind memory failed.
[   28.728877] radeon 0000:80:00.0: object_init failed for (4096, 0x0000000=
2)
[   28.728914] radeon 0000:80:00.0: (-22) create WB bo failed
[   28.728949] radeon 0000:80:00.0: Disabling GPU acceleration
[   28.728987] [drm] radeon: cp finalized
[   28.729031] [drm] radeon: cp finalized
[   28.729074] [TTM] Finalizing pool allocator.
[   28.729781] [TTM] Zone  kernel: Used memory at exit: 0 kiB.
[   28.729818] [TTM] Zone   dma32: Used memory at exit: 0 kiB.
[   28.729853] [drm] radeon: ttm finalized
[   28.729886] [drm] Forcing AGP to PCI mode
[   28.730743] [drm] Generation 1 PCI interface in multifunction mode
[   28.730778] [drm] Limiting VRAM to one aperture
[   28.730814] radeon 0000:80:00.0: VRAM: 256M 0x00000000D0000000 - 0x00000=
000DF
FFFFFF (256M used)
[   28.730864] radeon 0000:80:00.0: GTT: 512M 0x00000000B0000000 - 0x000000=
00CFF
FFFFF
[   28.730912] [drm] Supports vblank timestamp caching Rev 1 (10.10.2010).
[   28.730947] [drm] Driver supports precise vblank timestamp query.
[   28.730987] [drm] radeon: irq initialized.
[   28.731020] [drm] Detected VRAM RAM%6M, BAR=128M
[   28.731053] [drm] RAM width 256bits DDR
[   28.731138] [TTM] Zone  kernel: Available graphics memory: 3110864 kiB.
[   28.731187] [TTM] Zone   dma32: Available graphics memory: 2097152 kiB.
[   28.731222] [TTM] Initializing pool allocator.
[   28.731269] [drm] radeon: 256M of VRAM memory ready
[   28.731302] [drm] radeon: 512M of GTT memory ready.
[   28.731342] [drm] GART: num cpu pages 32768, num gpu pages 131072
[   28.732113] [drm] radeon: 2 quad pipes, 1 Z pipes initialized.
[   28.733721] radeon 0000:80:00.0: WB enabled
[   28.734008] [drm] Loading R300 Microcode
[   29.045898] [drm] radeon: ring at 0x00000000B0004000
[   29.045968] [drm] ring test succeeded in 2 usecs
[   29.046078] [drm] radeon: ib pool ready.
[   29.046242] [drm] ib test succeeded in 0 usecs
[   29.046544] [drm] No TV DAC info found in BIOS
[   29.046626] [drm] Radeon Display Connectors
[   29.046660] [drm] Connector 0:
[   29.046691] [drm]   DVI-I
[   29.046721] [drm]   HPD1
[   29.046753] [drm]   DDC: 0x60 0x60 0x60 0x60 0x60 0x60 0x60 0x60
[   29.046787] [drm]   Encoders:
[   29.046817] [drm]     CRT1: INTERNAL_DAC1
[   29.046850] [drm]     DFP1: INTERNAL_TMDS1
[   29.046882] [drm] Connector 1:
[   29.046913] [drm]   DVI-I
[   29.046943] [drm]   HPD2
[   29.046974] [drm]   DDC: 0x64 0x64 0x64 0x64 0x64 0x64 0x64 0x64
[   29.047008] [drm]   Encoders:
[   29.047039] [drm]     CRT2: INTERNAL_DAC2
[   29.047071] [drm]     DFP2: INTERNAL_DVO1
[   29.936059] [drm] fb mappable at 0xD0040000
[   29.936100] [drm] vram apper at 0xD0000000
[   29.936132] [drm] size 7684096
[   29.936163] [drm] fb depth is 24
[   29.936193] [drm]    pitch is 6400
[   30.185974] Console: switching to colour frame buffer device 200x75
[   30.375218] fb0: radeondrmfb frame buffer device
[   30.375220] drm: registered panic notifier
[   30.375231] [drm] Initialized radeon 2.8.0 20080528 for 0000:80:00.0 on =
minor
 0

<snip>

However, the same issue has been fixed in agp/amd-k7
(https://lkml.org/lkml/2010/10/15/469). I've thus simply replicated
this patch in agp/hp of my vanilla kernel 2.6.38.2 tree:

diff -uNr linux-2.6.38.2.vanilla/drivers/char/agp/hp-agp.c linux-2.6.38.2.n=
ew/dr
ivers/char/agp/hp-agp.c
--- linux-2.6.38.2.vanilla/drivers/char/agp/hp-agp.c	2011-03-27 20:37:20.00=
00
00000 +0200
+++ linux-2.6.38.2.new/drivers/char/agp/hp-agp.c	2011-04-12 21:20:46.0000
00000 +0200
@@ -336,7 +336,9 @@
 	off_t j, io_pg_start;
 	int io_pg_count;

-	if (type !=3D 0 || mem->type !=3D 0) {
+	if (type !=3D mem->type ||
+		agp_bridge->driver->agp_type_to_mask_type(agp_bridge, type)) {
+	//if (type !=3D 0 || mem->type !=3D 0) {
 		return -EINVAL;
 	}

@@ -380,7 +382,9 @@
 	struct _hp_private *hp =3D &hp_private;
 	int i, io_pg_start, io_pg_count;

-	if (type !=3D 0 || mem->type !=3D 0) {
+	if (type !=3D mem->type ||
+		agp_bridge->driver->agp_type_to_mask_type(agp_bridge, type)) {
+	//if (type !=3D 0 || mem->type !=3D 0) {
 		return -EINVAL;
 	}

I've then recompiled the modified kernel 2.6.38.2 tree. At reboot,
dmesg no more complains about AGP bind memory failure, disabled GPU
acceleration or AGP mode forced to PCI:

<snip>

[   28.066974] [drm] Initialized drm 1.1.0 20060810
[   28.678364] [drm] radeon kernel modesetting enabled.
[   28.678655] GSI 60 (level, low) -> CPU 1 (0x0100) vector 60
[   28.678693] radeon 0000:80:00.0: PCI INT A -> GSI 60 (level, low) -> IRQ=
 60
[   28.681786] [drm] initializing kernel modesetting (R300 0x1002:0x4E47).
[   28.681829] [drm] register mmio base: 0xD8030000
[   28.681862] [drm] register mmio size: 65536
[   28.684834] radeon 0000:80:00.0: putting AGP V2 device into 2x mode
[   28.685150] radeon 0000:80:00.0: GTT: 512M 0x60000000 - 0x7FFFFFFF
[   28.685242] [drm] Generation 1 PCI interface in multifunction mode
[   28.685277] [drm] Limiting VRAM to one aperture
[   28.685313] radeon 0000:80:00.0: VRAM: 256M 0x00000000D0000000 - 0x00000=
000DF
FFFFFF (256M used)
[   28.685370] [drm] Supports vblank timestamp caching Rev 1 (10.10.2010).
[   28.685405] [drm] Driver supports precise vblank timestamp query.
[   28.685465] [drm] radeon: irq initialized.
[   28.685497] [drm] Detected VRAM RAM%6M, BAR=128M
[   28.685530] [drm] RAM width 256bits DDR
[   28.685676] [TTM] Zone  kernel: Available graphics memory: 3110888 kiB.
[   28.685712] [TTM] Zone   dma32: Available graphics memory: 2097152 kiB.
[   28.685748] [TTM] Initializing pool allocator.
[   28.685941] [drm] radeon: 256M of VRAM memory ready
[   28.685976] [drm] radeon: 512M of GTT memory ready.
[   28.686064] [drm] radeon: 2 quad pipes, 1 Z pipes initialized.
[   28.687066] radeon 0000:80:00.0: WB disabled
[   28.687608] [drm] Loading R300 Microcode
[   28.973331] Linux video capture interface: v2.00
[   29.108431] GSI 38 (level, low) -> CPU 0 (0x0000) vector 61
[   29.108473] FM801 0000:40:01.0: PCI INT A -> GSI 38 (level, low) -> IRQ =
61
[   29.207736] [drm] radeon: ring at 0x0000000060004000
[   29.207816] [drm] ring test succeeded in 0 usecs
[   29.207886] [drm] radeon: ib pool ready.
[   29.208045] [drm] ib test succeeded in 0 usecs
[   29.208288] [drm] No TV DAC info found in BIOS
[   29.208360] [drm] Radeon Display Connectors
[   29.208393] [drm] Connector 0:
[   29.208424] [drm]   DVI-I
[   29.208454] [drm]   HPD1
[   29.208485] [drm]   DDC: 0x60 0x60 0x60 0x60 0x60 0x60 0x60 0x60
[   29.208519] [drm]   Encoders:
[   29.208550] [drm]     CRT1: INTERNAL_DAC1
[   29.208582] [drm]     DFP1: INTERNAL_TMDS1
[   29.208614] [drm] Connector 1:
[   29.208644] [drm]   DVI-I
[   29.208674] [drm]   HPD2
[   29.208705] [drm]   DDC: 0x64 0x64 0x64 0x64 0x64 0x64 0x64 0x64
[   29.208739] [drm]   Encoders:
[   29.208769] [drm]     CRT2: INTERNAL_DAC2
[   29.208801] [drm]     DFP2: INTERNAL_DVO1
[   30.097827] [drm] fb mappable at 0xD0040000
[   30.097861] [drm] vram apper at 0xD0000000
[   30.097893] [drm] size 7684096
[   30.097923] [drm] fb depth is 24
[   30.097953] [drm]    pitch is 6400
[   30.347409] Console: switching to colour frame buffer device 200x75
[   30.536596] fb0: radeondrmfb frame buffer device
[   30.537263] drm: registered panic notifier
[   30.537861] [drm] Initialized radeon 2.8.0 20080528 for 0000:80:00.0 on =
minor
 0

<snip>

I'm absolutely not a kernel programmer, so:
- is simply replicating the agp/amd-k7 patch in agp/hp the right way
to enable again 3D hardware acceleration on hp zx1? In this case, feel
free to reformat my proposed patch to conform to coding rules. BTW, a
similar patch should probably be written for i460 systems, but the
agp/i460 code is less clear to me and I no more have the hardware at
hands to test it;
- although not being reported anymore, is GPU acceleration really
working? Indeed, I'm still getting the exact same pathetic ~85fps in
average in glxgears as with vanilla 2.6.38.2.

Regards,

     =C9meric
