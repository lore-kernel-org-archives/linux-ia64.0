From: Christian Brauner <christian.brauner@ubuntu.com>
Date: Thu, 14 May 2020 13:00:25 +0000
Subject: Re: [PATCH] ia64: enable HAVE_COPY_THREAD_TLS, switch to kernel_clone_args
Message-Id: <20200514130025.hsvtcv3rdzwgowvd@wittgenstein>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200513204848.1208864-1-christian.brauner@ubuntu.com>
 <3908561D78D1C84285E8C5FCA982C28F7F6266E0@ORSMSX115.amr.corp.intel.com>
 <79e58d9b-5a39-390c-2f0c-0d87b63442b4@physik.fu-berlin.de>
 <20200514074606.vkc35syhdep23rzh@wittgenstein>
 <6b298416-1e64-eee7-0bb4-3b1f7f67adc6@physik.fu-berlin.de>
 <d6c94d4f-a431-9de5-7a0f-661894dbec01@physik.fu-berlin.de>
In-Reply-To: <d6c94d4f-a431-9de5-7a0f-661894dbec01@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Cc: "Luck, Tony" <tony.luck@intel.com>, "Yu, Fenghua" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Qais Yousef <qais.yousef@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, May 14, 2020 at 11:48:31AM +0200, John Paul Adrian Glaubitz wrote:
>=20
>=20
> On 5/14/20 9:53 AM, John Paul Adrian Glaubitz wrote:
> > The kernel is currently building, you should get it by the evening (CES=
T).
> >=20
> > The machine also serves as a Debian buildd which is why it's a bit more
> > busy than other servers.
> I applied the patch against 5.7-rc5, it applied fine and builds fine.
>=20
> It seems though that systemd crashes but I'm not sure it's related:
>=20
> [   14.267489] init[1]: General Exception: IA-64 Reserved Register/Field =
fault (data access) 2199023255600 [1]                    =20
> [   14.267489] Modules linked in:                                        =
                                                         =20
> [   14.267489]                                                           =
                                                         =20
> [   14.267489] CPU: 0 PID: 1 Comm: init Not tainted 5.7.0-rc5 #1         =
                                                         =20
> [   14.267489] Hardware name: hp server BL860c                   , BIOS 0=
4.25                                                            07/02/2010 =
                                                                           =
                                      =20
> [   14.267489] psr : 0000121008526030 ifs : 8000000000000510 ip  : [<a000=
00010000c541>]    Not tainted (5.7.0-rc5)                =20
> [   14.267489] ip is at sys_clone2+0x61/0x80                             =
                                                         =20
> [   14.267489] unat: 0000000000000000 pfs : 0000000000000510 rsc : 000000=
0000000003                                               =20
> [   14.267489] rnat: 0000000000000000 bsps: 0000000000000000 pr  : 000000=
000001a959                                               =20
> [   14.267489] ldrs: 0000000000000000 ccv : 0000000000000002 fpsr: 000980=
4c8a70033f                                               =20
> [   14.267489] csd : 0000000000000000 ssd : 0000000000000000             =
                                                         =20
> [   14.267489] b0  : a00000010000c540 b6  : a0000001000edf80 b7  : a00000=
0100369560                                               =20
> [   14.267489] f6  : 1003e000000000000b8a4 f7  : 1003e00000001754e8d69   =
                                                         =20
> [   14.267489] f8  : 1003e0000000178311d69 f9  : 100098000000000000000
> [   14.267489] f10 : 1000eb8a3fffff475c000 f11 : 1003e000000000000b8a4
> [   14.267489] r1  : a0000001017a6f10 r2  : 0000000000000000 r3  : 000000=
0000000006
> [   14.267489] r8  : 0000000000000066 r9  : 0000000000000060 r10 : e00001=
00800d8e68
> [   14.267489] r11 : 0000000000000002 r12 : e00001008027fe30 r13 : e00001=
0080278000
> [   14.267489] r14 : e0000100800d8e04 r15 : e0000100800d8e08 r16 : 000000=
0000000002
> [   14.267489] r17 : 0000000000000001 r18 : 0000000000000002 r19 : 000000=
0000000003
> [   14.267489] r20 : 0000000000000004 r21 : e00001008027fb98 r22 : e00000=
0001146d02
> [   14.267489] r23 : 00000000000030c8 r24 : 00000000000030c8 r25 : 000000=
00000030ca
> [   14.267489] r26 : 00000000000030ca r27 : 00000000000030ca r28 : e00001=
008027fb90
> [   14.267489] r29 : 0000000000000400 r30 : 00000000000002e8 r31 : 000000=
0000000400
> [   14.267489]=20
> [   14.267489] Call Trace:
> [   14.267489]  [<a000000100015090>] show_stack+0x90/0xc0
> [   14.267489]                                 sp=E00001008027f9f0 bsp=E0=
00010080279288
> [   14.267489]  [<a000000100015780>] show_regs+0x6c0/0xa20
> [   14.267489]                                 sp=E00001008027fbc0 bsp=E0=
00010080279218
> [   14.267489]  [<a000000100029590>] die+0x1b0/0x4a0
> [   14.267489]                                 sp=E00001008027fbe0 bsp=E0=
000100802791d0
> [   14.267489]  [<a00000010100e690>] ia64_fault+0x770/0xd80
> [   14.267489]                                 sp=E00001008027fbe0 bsp=E0=
00010080279180
> [   14.267489]  [<a00000010000ce60>] ia64_leave_kernel+0x0/0x270
> [   14.267489]                                 sp=E00001008027fc60 bsp=E0=
00010080279180
> [   14.267489]  [<a00000010000c540>] sys_clone2+0x60/0x80
> [   14.267489]                                 sp=E00001008027fe30 bsp=E0=
00010080279100
> [   14.267489] Disabling lock debugging due to kernel taint
> [   14.267489] init[102]: General Exception: IA-64 Reserved Register/Fiel=
d fault (data access) 4398046511152 [2]
> [   14.350730] Kernel panic - not syncing: Attempted to kill init! exitco=
de=3D0x0000000b
>     [1 4 . 31540.733500]7 3-0-]- [- -e-n[d  eKnedr nKeelr npealn pani[c  =
 -  1n4o.t2 6s7y4n8c9i]n g:
> :Attem [D      1 4 . 2 6 7 4 8 95]. 7C.P0U-:r c15  P#I1D
> i e1=002x 0C0o0m0m0:0 0ibn i]t- -T-a
>  nted: G      D           5.7.0-rc5 #1
>=20
> I have to perform more testing. The machine boots fine with a 5.5.x kerne=
l.

Ok, so the good news is that from our other mail exchange we know that
it doesn't boot on 5.6 without my patch too.

Christian
