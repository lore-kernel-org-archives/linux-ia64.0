From: jilee11@comcast.net
Date: Tue, 11 May 2004 21:07:19 +0000
Subject: Load of Auxiliary Floating Point Driver failed: Unsupported
Message-Id: <051120042107.9439.40A140870006E49A000024DF2200735834FFCECE9A9A9396@comcast.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


An old IPF1 server (Lion) pauses during booting with a failure as shown bel=
ow and it pauses for key input. After hitting a key to continue the boot, L=
inux boots ok and displays an FPSWA if addr and revision.
I looked at the efi partition and there were two different copies of fpswa.=
efi- on in /boot/efi/efi/Intel Firmware/ and the other in /boot/efi/efi/Mic=
rosoft/.
This failure happens only with Linux boot disk but didn't happen with Windo=
ws2000 boot disk.=20
How can I fix/get arround this or at least not to pause the boot ?=20
=20
Thanks,
John

BIOS Version S460AC4A.86B.0083.B.0106070029
Loading device drivers

Loading.: Auxiliary Floating Point Driver
Load of Auxiliary Floating Point Driver failed: Unsupported
Paused =96 press any key to continue
