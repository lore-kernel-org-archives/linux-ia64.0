From: =?UTF-8?Q?=C3=89meric_MASCHINO?= <emeric.maschino@gmail.com>
Date: Thu, 22 May 2014 23:02:38 +0000
Subject: How to deal with ia32 binary support nowadays?
Message-Id: <CAA9xbM5FcvA3Ps5-wmsHzpYw8Pn89Sy3sS2L2Nn1=ae9A827mQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi,

Tony removed support of ia32 binaries back in 2010. ia32 support was
supposedly broken since Al Viro killed altroot in 2008 [2]. I've no
clue what altroot is and what's its relationship with ia32 support,
but even without altroot, x86_64 still can execute ia32 binaries, a
(large?) part of the ia32 support coming from ia64 [3]. How is that
x86_64 can run ia32 binaries and no more ia64? There was also talk
about merging ia64 implementation with x86_64 one some times ago [4],
but I don't know how all this ended (by copying part of ia64
implementation into x86_64 as alluded to earlier? In this case, it's
code duplication, not merge).

An alternative is using Intel's proprietary IA-32 EL software, that
cannot be found anymore on Earth...

How do you deal with (rare) ia32 binaries on ia64 nowadays?

     =C3=89meric


[1] http://marc.info/?l=3Dlinux-ia64&m=126565735012367&w=3D2
[2] http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?=
id=7F2da1e7d0330395e5e9e350b879b98a1ea495df
[3] http://marc.info/?l=3Dlinux-ia64&m=126665829806428&w=3D2
[4] http://marc.info/?l=3Dlinux-ia64&m=114851556409633&w=3D2
