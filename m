From: Thibaut VARENE <T-Bone@parisc-linux.org>
Date: Wed, 29 Sep 2004 07:47:42 +0000
Subject: Re: kernel troubles on rx2600 while running sbuild
Message-Id: <20040929094742.38e580d3.T-Bone@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040926183333.1592f4cd@Tatooine.r3z0>
In-Reply-To: <20040926183333.1592f4cd@Tatooine.r3z0>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Wed, 29 Sep 2004 09:17:20 +0200
Thibaut VARENE <T-Bone@parisc-linux.org> wrote:

> Hi,
>=20
> Another report, that happened tonight while the box was idling (after
> having built quite a lot of packages - about 1000 - without problems),
> and which was apparently triggered by a cron task (at 5 AM). There
> again (see at the end) there's a kernel NULL pointer dereference. Full
> dump attached.
>=20
> rx2600 1-way 2GB RAM
> Debian sarge, kernel-image-2.4.27-mckinley

After rebooting, it appeared that the last build the box was running
(gcc-3.4) didn't complete, though the box was actually idle when it died
(according to mrtg reports). For the records, i've seen my glibc build
get stalled (ie: the box gets idle and no progress is made) in the test
suite a little before gcc was being built.

So, on the same box after a fresh reboot, trying to "du -sh" an unclean
gcc-3.4 build directory (i tried twice) made du to segfault and dmesg to
show the following (note, i tried du on other stuff and it worked
without problem):

Unable to handle kernel paging request at virtual address
00000000000100a6 du[3608]: Oops 8813272891392

Pid: 3608, CPU 0, comm:                   du
psr : 0000101008026018 ifs : 8000000000000690 ip  : [<e0000000044da450>]
   Not tainted ip is at (no symbol)
unat: 0000000000000000 pfs : 0000000000000690 rsc : 0000000000000003
rnat: 0000000000000010 bsps: 0000000000000000 pr  : 80000000ff56a659
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c0270033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : e0000000044da3f0 b6  : e000000004494020 b7  : a00000000009ee00
f6  : 1003e0000000000001000 f7  : 000000000000000000000
f8  : 000000000000000000000 f9  : 1000b8000000000000000
f10 : 000000000000000000000 f11 : 1003e0000000000000000
r1  : e000000004b2ee70 r2  : 000000000001003e r3  : e000000034258a88
r8  : 0000000000000000 r9  : e000000034258980 r10 : e00000003438cf88
r11 : 0000000000000002 r12 : e00000000fc5fe00 r13 : e00000000fc58000
r14 : 000000000000f96e r15 : 00000000000100a6 r16 : 0000000000000000
r17 : e00000003f3e2388 r18 : e00000003f3f15e8 r19 : e00000003f3f15d0
r20 : e00000003f3e2388 r21 : 00000000000ab7ba r22 : e000000001025928
r23 : 000000000004df26 r24 : 000000003e5b8000 r25 : e00000003f3f15e0
r26 : e00000000493ce48 r27 : 2000000000000000 r28 : e00000000493ce48
r29 : e00000003f3f15d8 r30 : e00000003f3f15d0 r31 : e00000003f3f15c8

Call Trace:
 [<e000000004413e80>] (no symbol)
                                sp=E00000000fc5f9d0 bsp=E00000000fc59030
 [<e00000000442e330>] (no symbol)
                                sp=E00000000fc5fba0 bsp=E00000000fc58ff0
 [<e000000004449910>] (no symbol)
                                sp=E00000000fc5fba0 bsp=E00000000fc58f90
 [<e00000000440eb20>] (no symbol)
                                sp=E00000000fc5fc30 bsp=E00000000fc58f90
 [<e0000000044da450>] (no symbol)
                                sp=E00000000fc5fe00 bsp=E00000000fc58f10
 [<e00000000440e920>] (no symbol)
                                sp=E00000000fc5fe30 bsp=E00000000fc58ef8
 <1>Unable to handle kernel paging request at virtual address
00000000000100a6 du[3646]: Oops 8813272891392

Pid: 3646, CPU 0, comm:                   du
psr : 0000101008026018 ifs : 8000000000000690 ip  : [<e0000000044da450>]
   Not tainted ip is at (no symbol)
unat: 0000000000000000 pfs : 0000000000000690 rsc : 0000000000000003
rnat: 0000000000000010 bsps: 00000000000db3da pr  : 80000000ff56a659
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c0270033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : e0000000044da3f0 b6  : e000000004494020 b7  : a00000000009ee00
f6  : 1003e0000000000001000 f7  : 000000000000000000000
f8  : 000000000000000000000 f9  : 1000b8000000000000000
f10 : 000000000000000000000 f11 : 1003e0000000000000000
r1  : e000000004b2ee70 r2  : 000000000001003e r3  : e000000034258a88
r8  : 0000000000000000 r9  : e000000034258980 r10 : e00000003438cf88
r11 : 0000000000000002 r12 : e00000000fccfe00 r13 : e00000000fcc8000
r14 : 000000000000f96e r15 : 00000000000100a6 r16 : 0000000000000000
r17 : e00000003f3e2388 r18 : e00000003f3f15e8 r19 : e00000003f3f15d0
r20 : e00000003f3e2388 r21 : 00000000000ab7ba r22 : e000000001025928
r23 : 000000000004df26 r24 : 000000003e5b8000 r25 : e00000003f3f15e0
r26 : e00000000493ce48 r27 : 2000000000000000 r28 : e00000000493ce48
r29 : e00000003f3f15d8 r30 : e00000003f3f15d0 r31 : e00000003f3f15c8

Call Trace:
 [<e000000004413e80>] (no symbol)
                                sp=E00000000fccf9d0 bsp=E00000000fcc9030
 [<e00000000442e330>] (no symbol)
                                sp=E00000000fccfba0 bsp=E00000000fcc8ff0
 [<e000000004449910>] (no symbol)
                                sp=E00000000fccfba0 bsp=E00000000fcc8f90
 [<e00000000440eb20>] (no symbol)
                                sp=E00000000fccfc30 bsp=E00000000fcc8f90
 [<e0000000044da450>] (no symbol)
                                sp=E00000000fccfe00 bsp=E00000000fcc8f10
 [<e00000000440e920>] (no symbol)
                                sp=E00000000fccfe30 bsp=E00000000fcc8ef8
=20

HTH,

Thibaut VARENE
The PA/Linux ESIEE Team
http://www.pateam.org/
