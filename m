From: Russ Anderson <rja@sgi.com>
Date: Mon, 30 Apr 2007 23:07:58 +0000
Subject: Re: [patch] Support multiple CPUs going through OS_MCA
Message-Id: <200704302307.l3UN7w2I58788357@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200704272129.l3RLT8Ob64391823@clink.americas.sgi.com>
In-Reply-To: <200704272129.l3RLT8Ob64391823@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Yu, Fenghua wrote:
>=20
> >+	if (r13 !=3D sos->prev_IA64_KR_CURRENT) {
> >+		msg =3D "inconsistent previous current and r13";
> >+		goto no_mod;
> >+	}
> >+
> > 	if (!mca_recover_range(ms->pmsa_iip)) {
> >-		if (r13 !=3D sos->prev_IA64_KR_CURRENT) {
> >-			msg =3D "inconsistent previous current and r13";
> >-			goto no_mod;
> >-		}
>=20
> Could you explain whey move the r13 check out of mca_recover_range()?

For my test cases, I can hit cases an MCA without that change (output
below) if the MCA surfaces in the interrupt IVT (address in mca_recover_ran=
ge()).
The MCA is due to old_bspstore not having a valid virtual address.

--------------------------------------------------------------------------
run test 163
cpu 0, MCA occurred in user space, original stack not modified
Unable to handle kernel paging request at virtual address 603fffffff850048
MCA 4179[0]: Oops 8804682956800 [1]
Modules linked in: errinj

Pid: 0, CPU 1, comm:             MCA 4179
psr : 0000101808022030 ifs : 800000000000122c ip  : [<a000000100044a10>]   =
 Not tainted
ip is at ia64_mca_modify_original_stack+0x1110/0x1240
unat: 0000000000000000 pfs : 000000000000122c rsc : 0000000000000003
rnat: 0000000000000000 bsps: 0000000000000000 pr  : 000000560055a9a7
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a0000001000449a0 b6  : 4000000000003c40 b7  : a000000000010640
f6  : 000000000000000000000 f7  : 0ffdba200000000000000
f8  : 100018000000000000000 f9  : 10002a000000000000000
f10 : 0fffdccccccccc8c00000 f11 : 1003e0000000000000000
r1  : a000000100f69a00 r2  : 607fffffff84ae58 r3  : 0000000000550281
r8  : 0000000000000000 r9  : 607fffffff84ae40 r10 : 0000000000000000
r11 : 0000000000000000 r12 : e000006007067ac0 r13 : e000006007060000
r14 : 0000000000000001 r15 : e000006007060ce8 r16 : 0000000000000005
r17 : 0000000000000000 r18 : 0000000000000000 r19 : 0000000000000000
r20 : 0000000000000000 r21 : 0000000000000000 r22 : 8000000000000000
r23 : 0000000000000000 r24 : 000000000000003e r25 : 000000000000003f
r26 : 0000000000000009 r27 : 0000000000000000 r28 : 4000000000000000
r29 : 0000000000000000 r30 : 0000000000000000 r31 : c0000000000111c8

Call Trace:
 [<a0000001000125e0>] show_stack+0x40/0xa0
                                sp=E000006007067670 bsp=E000006007061088
 [<a000000100012ee0>] show_regs+0x840/0x880
                                sp=E000006007067840 bsp=E000006007061030
 [<a000000100034910>] die+0x250/0x320
                                sp=E000006007067840 bsp=E000006007060fe0
 [<a0000001000592f0>] ia64_do_page_fault+0x930/0xa60
                                sp=E000006007067860 bsp=E000006007060f90
 [<a00000010000b520>] ia64_leave_kernel+0x0/0x290
                                sp=E0000060070678f0 bsp=E000006007060f90
 [<a000000100044a10>] ia64_mca_modify_original_stack+0x1110/0x1240
                                sp=E000006007067ac0 bsp=E000006007060e30
 [<a000000100045ad0>] ia64_mca_handler+0x170/0xb20
                                sp=E000006007067ad0 bsp=E000006007060dd0
 [<a000000100047420>] ia64_os_mca_virtual_begin+0x40/0x140
                                sp=E000006007067b80 bsp=E000006007060dd0
Kernel panic - not syncing: Attempted to kill the idle task!
--------------------------------------------------------------------------

> >+		for_each_online_cpu(i) {
> >+			if (cpu_isset(i, mca_cpu)) {
> >+				monarch_cpu =3D i;
> >+				cpu_clear(i, mca_cpu);	/* wake next cpu
> */
>=20
> Just a picky comment...Is it better to changed to
> + if (mca_cpu!=3D0) {
> +		for_each_online_cpu(i) {
> +			if (cpu_isset(i, mca_cpu)) {
> +				monarch_cpu =3D i;
> +				cpu_clear(i, mca_cpu);	/* wake next cpu
> */
>=20
> it may speed up a bit?. After all in reality, there are few bits set in
> mca_cpu. So there is no need to go through all of online cpus.

That section of code only gets executed if mca_cpu !=3D 0, due to=20
this line:=20

        if (atomic_dec_return(&mca_count) > 0) {

If mca_count is greater than 0, there is a bit set.
If mca_count =3D 0, there are no bits set and the code is skipped.

> Thanks.
>=20
> -Fenghua
>=20

Thanks,
--=20
Russ Anderson, OS RAS/Partitioning Project Lead =20
SGI - Silicon Graphics Inc          rja@sgi.com
