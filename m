From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 27 Oct 2006 13:28:11 +0000
Subject: Re: [BUGFIX] [PATCH 1/2] cpu-hotplug: Fixing confliction between
Message-Id: <20061027222811.900b8008.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <87mz7ivxri.wl%takeuchi_satoru@jp.fujitsu.com>
In-Reply-To: <87mz7ivxri.wl%takeuchi_satoru@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, ashok.raj@intel.com, tony.luck@intel.com, akpm@osdl.org, kaneshige.kenji@jp.fujitsu.com, takeuchi_satoru@jp.fujitsu.com

On Fri, 27 Oct 2006 19:49:53 +0900
Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com> wrote:

> Fixing the confliction between CPU hot-add and IPI.
>=20
Some more verbose inoformation ;)

This patch fixes following bug. found in our test.
=3D
Pid: 7905, CPU 4, comm:              memload
psr : 0000121008022018 ifs : 800000000000038a ip  : [<a000000100054681>]   =
 Not
tainted
ip is at handle_IPI+0x101/0x380
unat: 0000000000000000 pfs : 000000000000040b rsc : 0000000000000003
rnat: 0000000000565aa9 bsps: a0000001000943b0 pr  : 00000000005685a9
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c0270033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a0000001000e4340 b6  : a000000100054580 b7  : a000000000010640
f6  : 000000000000000000000 f7  : 000000000000000000000
f8  : 000000000000000000000 f9  : 1003effffffffffffc000
f10 : 1003e0000000000000000 f11 : 000000000000000000000
r1  : a000000100c14e40 r2  : fffffffffffffffe r3  : fffffffffffffffe
r8  : 0000000000000001 r9  : 0000000000000000 r10 : 0000000000000000
r11 : 0000000000017d00 r12 : e0000001341dfe30 r13 : e0000001341d8000
r14 : 0000000000000001 r15 : e0000140040165f8 r16 : a000000100861400
r17 : 0000000000000000 r18 : 0000000000000010 r19 : a000000100a2cc48
r20 : 00000000000002fa r21 : ffffffffffff0028 r22 : a0000001009ce2c0
r23 : a0000001009ce298 r24 : a000000100011a60 r25 : e0000001341dfe58
r26 : c000000000000008 r27 : 000000000000000f r28 : a000000000010620
r29 : a000000100879120 r30 : 0000000000000008 r31 : 0000000000550a41

Call Trace:
 [<a000000100013e80>] show_stack+0x40/0xa0
                                sp=E0000001341df9c0 bsp=E0000001341d9338
 [<a000000100014780>] show_regs+0x840/0x880
                                sp=E0000001341dfb90 bsp=E0000001341d92e0
 [<a000000100037b60>] die+0x1c0/0x2a0
                                sp=E0000001341dfb90 bsp=E0000001341d9298
 [<a000000100629040>] ia64_do_page_fault+0x8a0/0x9e0
                                sp=E0000001341dfbb0 bsp=E0000001341d9248
 [<a00000010000c700>] __ia64_leave_kernel+0x0/0x280
                                sp=E0000001341dfc60 bsp=E0000001341d9248
 [<a000000100054680>] handle_IPI+0x100/0x380
                                sp=E0000001341dfe30 bsp=E0000001341d91f0
 [<a0000001000e4340>] handle_IRQ_event+0xa0/0x140
                                sp=E0000001341dfe30 bsp=E0000001341d91b0
 [<a0000001000e4510>] __do_IRQ+0x130/0x3e0
                                sp=E0000001341dfe30 bsp=E0000001341d9168
 [<a000000100011990>] ia64_handle_irq+0xf0/0x1a0
                                sp=E0000001341dfe30 bsp=E0000001341d9138
 [<a00000010000c700>] __ia64_leave_kernel+0x0/0x280
                                sp=E0000001341dfe30 bsp=E0000001341d9138
 <3>BUG: sleeping function called from invalid context at kernel/rwsem.c:20
in_atomic():1, irqs_disabled():0
=3D
This is because handle_IPI() accesses call_data, which is NULL.

The scenario is

1. on CPU A: smp_call_funcion() is called.
2. on CPU A: ncpus =3D num_online_cpus() - 1 is called. set ncpus=3DX.
3. on CPU B: by cpu_hotplug, some cpus comes up to be online. changes onlin=
e_map.
4. on CPU A: smp_call_function() sends IPI. The targets of IPI is determine=
d by
   cpu_online_map(), which was changed. Then, IPIs are sent to *X+1* proces=
sors.
5. on CPU A: wait for X(=3Dncpus) acks.=20
6. on CPU A: after getting all Acks. set call_data =3D NULL
7. on some other cpu, which received *delayed* IPI(by some irq-disable ops)
   will access call_data and panics.

This patch moves ncpus=3Dnum_online_cpu() under ipi_call_lock.
x86 implemtation does this.=20

-Kame

