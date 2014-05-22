From: =?UTF-8?Q?=C3=89meric_MASCHINO?= <emeric.maschino@gmail.com>
Date: Thu, 22 May 2014 17:09:52 +0000
Subject: Outdated configuration files in arch/ia64/configs
Message-Id: <CAA9xbM4urvd_S=S66p-6=YN0VK0NuyoDRctsVgHZ9vu3Nrhh0w@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi,

As alluded to earlier [1], I'm wondering how the various ia64 default
kernel configuration files in arch/ia64/configs are maintained?

For example, the zx1_defconfig file is pretty outdated, leading to
e.g. broken 3D hardware acceleration on zx1-based systems for many
years [1], just because the timer interrupt frequency hasn't been
overidden there appropriately when the selectable timer interrupt
frequency was introduced in May 2005 [2]. zx1-based systems thus
inherit a default 250 HZ timer frequency from other generic (read,
non-ia64) default kernel configuration files that is unfortunately
used by the various Linux distributions to provide prebuilt kernel
binary packages.

Similarly, the zx1_defconfig file still adds to the kernel the CMD649
chipset using the deprecated ATA/ATAPI/MFM/RLL API (CONFIG_IDE=3Dy,
CONFIG_BLK_DEV_IDECD=3Dy, CONFIG_BLK_DEV_CMD64X=3Dy) whereas the SATA/PATA
API is the way to go nowadays (CONFIG_ATA_SFF=3Dy, CONFIG_ATA_BMDMA=3Dy,
CONFIG_PATA_CMD64X=3Dy).

     =C3=89meric


[1] http://marc.info/?l=3Dlinux-ia64&m=140077543819871&w=3D2
[2] http://marc.info/?l=3Dlinux-ia64&m=111643909323936&w=3D2
