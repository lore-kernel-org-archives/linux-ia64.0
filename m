From: Thibaut VARENE <T-Bone@parisc-linux.org>
Date: Wed, 29 Sep 2004 07:17:20 +0000
Subject: Re: kernel troubles on rx2600 while running sbuild
Message-Id: <20040929091720.3a46860f.T-Bone@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040926183333.1592f4cd@Tatooine.r3z0>
In-Reply-To: <20040926183333.1592f4cd@Tatooine.r3z0>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi,

Another report, that happened tonight while the box was idling (after
having built quite a lot of packages - about 1000 - without problems),
and which was apparently triggered by a cron task (at 5 AM). There
again (see at the end) there's a kernel NULL pointer dereference. Full
dump attached.

rx2600 1-way 2GB RAM
Debian sarge, kernel-image-2.4.27-mckinley


start-stop-daem[9393]: NaT consumption 2216203124768

Pid: 9393, CPU 0, comm:      start-stop-daem
psr : 0000121008022038 ifs : 800000000000070f ip  : [<e00000000446f311>]
   Not tainted ip is at (no symbol)
unat: 0000000000000000 pfs : 000000000000048f rsc : 0000000000000003
rnat: 00000fffffffbfff bsps: 0000000000007fa8 pr  : 8000006af6556699
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c0270033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : e0000000046490c0 b6  : e0000000044cf1e0 b7  : e000000004648250
f6  : 1003e0000000000000008 f7  : 000000000000000000000
f8  : 1003e0000000000bfcde8 f9  : 1003e000000000017f9bd
f10 : 1003e000000000000766c f11 : 1003e00000000000516a4

r1  : e000000004b2ee70 r2  : 0000000000000080 r3  : e00000000494eb4c
r8  : 0000000000000000 r9  : 0000000000000000 r10 : e00000000494eb40
r11 : 0000000000000001 r12 : e00000000621fb30 r13 : e000000006218000
r14 : 000000000225cb5c r15 : e00000000494ed4c r16 : e00000003f399760
r17 : 0000000000000000 r18 : e00000003f399768 r19 : 000000000225cb64
r20 : 0000000000000008 r21 : 0000000000000003 r22 : 0000000000000803
r23 : e000000004648250 r24 : ffffffffffe1db88 r25 : e00000000482a6c8
r26 : 0000000000000028 r27 : e00000000482a6a0 r28 : e000000004930550
r29 : e0000000040af3e0 r30 : 0000000000000000 r31 : 00000000004da072

Call Trace:
 [<e000000004413e80>] (no symbol)
                                sp=E00000000621f690 bsp=E000000006219280
 [<e00000000442e330>] (no symbol)
                                sp=E00000000621f860 bsp=E000000006219248
 [<e00000000442f020>] (no symbol)
                                sp=E00000000621f860 bsp=E000000006219200
 [<e00000000440eb20>] (no symbol)
                                sp=E00000000621f960 bsp=E000000006219200
 [<e00000000446f310>] (no symbol)
                                sp=E00000000621fb30 bsp=E000000006219180
 [<e0000000046490c0>] (no symbol)
                                sp=E00000000621fb30 bsp=E000000006219138
 [<e0000000044cf600>] (no symbol)
                                sp=E00000000621fb30 bsp=E0000000062190a0
 [<a000000000087bf0>] (no symbol)
                                sp=E00000000621fc30 bsp=E000000006219078
 [<e0000000044a4880>] (no symbol)
                                sp=E00000000621fc30 bsp=E000000006218fb8
 [<e0000000044a5520>] (no symbol)
                                sp=E00000000621fc30 bsp=E000000006218f50
 [<e0000000044dbbb0>] (no symbol)
                                sp=E00000000621fc50 bsp=E000000006218f10
 [<e0000000044dd820>] (no symbol)
                                sp=E00000000621fc60 bsp=E000000006218ea8
 [<e000000004415400>] (no symbol)
                                sp=E00000000621fe30 bsp=E000000006218e30
 [<e00000000440e110>] (no symbol)
                                sp=E00000000621fe30 bsp=E000000006218e08
 [<e00000000440eb00>] (no symbol)
                                sp=E00000000621fe30 bsp=E000000006218dd0

 <1>Unable to handle kernel NULL pointer dereferenceswapper[0]: Oops
11012296146944

Pid: 0, CPU 0, comm:              swapper
psr : 0000121008022018 ifs : 800000000000070f ip  : [<e00000000446f311>]
   Not tainted ip is at (no symbol)
unat: 0000000000000000 pfs : 0000000000000207 rsc : 0000000000000003
rnat: 000000000000038a bsps: 0000000000000003 pr  : 80000000ff556a65
ldrs: 0000000000000000 ccv : 000000000000001d fpsr: 0009804c0270033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : e0000000044c9d00 b6  : e000000004403310 b7  : e0000000044cbda0
f6  : 1003e00000000000000de f7  : 0ffebdcc4a9ae00000000
f8  : 1003e0000000000097c80 f9  : 1003e0000000000005340
f10 : 1003e0000000000000060 f11 : 1003e00000000000012f9
r1  : e000000004b2ee70 r2  : 000000000000011d r3  : 000000000000011d
r8  : 000000000000011d r9  : 000000000000011d r10 : 000000000000011d
r11 : 000000000000011d r12 : e0000000048abba0 r13 : e0000000048a4000
r14 : 000000000000001d r15  000000000000011d r16 : 000000000000001d
r17 : 0000000000000000 r18 : e00000002c2589a0 r19 : 000000000000001d
r20 : 0000000000000019 r21 : 000000000000001d r22 : 000000000000006a
r23 : 000000000000015d r24 : 000000000000011d r25 : 000000000000015d
r26 : 0000000000001800 r27 : 000000000000006a r28 : 0000000000002000
r29 : 0000000000000800 r30 : e00000003f399754 r31 : e00000003f399758

Call Trace:
 [<e000000004413e80>] (no symbol)
                                sp=E0000000048ab770 bsp=E0000000048a5708
 [<e00000000442e330>] (no symbol)
                                sp=E0000000048ab940 bsp=E0000000048a56d0
 [<e000000004449910>] (no symbol)
                                sp=E0000000048ab940 bsp=E0000000048a5670
 [<e00000000440eb20>] (no symbol)
                                sp=E0000000048ab9d0 bsp=E0000000048a5670
 [<e00000000446f310>] (no symbol)
                                sp=E0000000048abba0 bsp=E0000000048a55f0
 [<e0000000044c9d00>] (no symbol)
                                sp=E0000000048abba0 bsp=E0000000048a55d0
 [<e0000000044cbed0>] (no symbol)
                                sp=E0000000048abba0 bsp=E0000000048a5598
 [<e0000000046665b0>] (no symbol)
                                sp=E0000000048abba0 bsp=E0000000048a54d8
 [<e000000004666cb0>] (no symbol)
                                sp=E0000000048abba0 bsp=E0000000048a5438
 [<e0000000046863a0>] (no symbol)
                                sp=E0000000048abba0 bsp=E0000000048a53d8
 [<e000000004663d30>] (no symbol)
                                sp=E0000000048abbb0 bsp=E0000000048a5368
 [<a0000000000349f0>] (no symbol)
                                sp=E0000000048abbb0 bsp=E0000000048a52f8
 [<a00000000001c3a0>] (no symbol)
                                sp=E0000000048abbb0 bsp=E0000000048a5210
 [<e000000004411700>] (no symbol)
                                sp=E0000000048abbb0 bsp=E0000000048a51d0
 [<e000000004411d40>] (no symbol)
                                sp=E0000000048abbb0 bsp=E0000000048a5190
 [<e0000000044134f0>] (no symbol)
                                sp=E0000000048abbb0 bsp=E0000000048a5158
 [<e00000000440eb20>] (no symbol)
                                sp=E0000000048abbb0 bsp=E0000000048a5158
 [<e000000004413a40>] (no symbol)
                                sp=E0000000048abd80 bsp=E0000000048a4e50
 [<e000000004414770>] (no symbol)
                                sp=E0000000048abd80 bsp=E0000000048a4e30
 [<e000000004414900>] (no symbol)
                                sp=E0000000048abe20 bsp=E0000000048a4e00
 [<e000000004409090>] (no symbol)
                                sp=E0000000048abe20 bsp=E0000000048a4de0
 [<e000000004878cc0>] (no symbol)
                                sp=E0000000048abe20 bsp=E0000000048a4d80
 [<e0000000044085e0>] (no symbol)
                                sp=E0000000048abe30 bsp=E0000000048a4d80
 <0>Kernel panic: Aiee, killing interrupt handler!
In interrupt handler - not syncing
=20



