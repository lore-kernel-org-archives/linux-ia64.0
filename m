From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Thu, 07 Sep 2006 08:45:40 +0000
Subject: RE: [Fastboot] [PATCH]IA64 kexec/kdump patch for INIT
Message-Id: <08B1877B2880CE42811294894F33AD5C053BF9@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <82C6D21B8B7A9Cindou.takao@jp.fujitsu.com>
In-Reply-To: <82C6D21B8B7A9Cindou.takao@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org



> -----Original Message-----
> From: Takao Indoh [mailto:indou.takao@jp.fujitsu.com]
> Sent: 2006=C4=EA9=D4=C27=C8=D5 11:21
> To: Zou, Nanhai
> Cc: Keith Owens; linux-ia64@vger.kernel.org; fastboot@lists.osdl.org
> Subject: RE: [Fastboot] [PATCH]IA64 kexec/kdump patch for INIT
>=20
> On Thu, 7 Sep 2006 09:32:38 +0800, "Zou, Nanhai" wrote:
>=20
> >> On Thu, 7 Sep 2006 08:57:13 +0800, "Zou, Nanhai" wrote:
> >>
> >> >> On Wed, 06 Sep 2006 18:06:53 +0900, Takao Indoh wrote:
> >> >>
> >> >> >>>+		/* change region of gp to region5 */
> >> >> >>>+		asm volatile ("movl gp=3D__gp"::: "memory");
> >> >> >>
> >> >> >>Why?  gp is already pointing at the kernel code before we enter
> >> >> >>ia64_init_handler().
> >> >> >
> >> >> >The purpose of this code is just changing region of gp from region=
7 to
> >> >> >region5. For example, if gp is e000000004ace170, I want to change =
gp
> to
> >> >>                                 ~~~~~~~~~~~~~~~~e000000000ace170
> >> >> Sorry, I mistook address...
> >> >>
> >> >>
> >> >> Regards,
> >> >> Takao Indoh
> >> >>
> >> >  You don't need to set gp here. Control page does not use GP, and
> >> >purgatory code will set GP to a physical address which was pre-calcul=
ated
> >> >at the time of crash kernel loading.
> >>
> >> If gp points region7, panic occurs at kdump_disable_iosapic.
> >>
> >> kdump_disable_iosapic(void)
> >> {
> >> 	u32 low32;
> >> 	struct iosapic_intr_info *info;
> >> 	struct iosapic_rte_info *rte;
> >> 	for (info =3D iosapic_intr_info; info <
> >> 			iosapic_intr_info + IA64_NUM_VECTORS; ++info) {
> >> 		low32 =3D info->low32 |=3D IOSAPIC_MASK;
> >> 		list_for_each_entry(rte, &info->rtes,
> >> 				rte_list) {
> >> (snip)
> >>
> >> The panic occurs at list_for_each_entry. When I found this problem,
> >> &info->rtes and rte->rte_list pointed same data but they had different
> >> address.
> >>
> >> &info->rtes   =3D> 0xe0000000049231e0
> >> rte->rte_list =3D> 0xa0000001009231e0
> >>
> >> info->rtes points region7 because its address is calculated from gp.
> >> This difference of address caused panic.
> >>
> >> Regards,
> >> Takao Indoh
> >>
> >
> >  Ok, ia64_setreg should be better.
> >We should avoid put inline asm code in C file.
>=20
> Yes, at first I used ia64_setreg, but this problem was not solved.
>=20
> 	if (sos->rv_rc !=3D 1 && (kdump_send_ipi || kdump_on_init)) {
> 		extern char __gp[];
> 		local_irq_disable();
> 		set_curr_task(cpu, previous_current);
>=20
> 		/* change region of gp to region5 */
> 		ia64_setreg(_IA64_REG_GP, __gp);
> 		crash_kexec(regs);
>=20
>=20
> The disassemble code:
> a000000100047080:       0b 38 01 02 00 24       [MMI]       addl r39=3D0,=
r1;;
> a000000100047086:       50 02 9c 00 42 00                   mov r37=3Dr39
> a00000010004708c:       00 00 04 00                         nop.i 0x0;;
> a000000100047090:       0a 08 00 4a 00 21       [MMI]       mov r1=3Dr37;;
> a000000100047096:       c0 02 80 00 42 00                   mov r44=3Dr32
> a00000010004709c:       00 00 04 00                         nop.i 0x0
> a0000001000470a0:       17 00 02 51 02 14       [BBB]
> br.call.sptk.many b0=A0000001000db4a0 <crash_kexec>
>=20
> This disassembled code does not change content of r1.
> Am I missing something?
>=20
  That is strange...

  For the crash_kexec code, only 1 cpu need execute crash_kexec which will =
boot the second kernel, While other cpus could wait in spin loop.=20
  So we can choose the monarch CPU in from notify_die chain after the monar=
ch/slave walkaround.
  Thanks
  Zou Nan hai

> Regards,
> Takao Indoh
