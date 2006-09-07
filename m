From: Takao Indoh <indou.takao@jp.fujitsu.com>
Date: Thu, 07 Sep 2006 03:21:20 +0000
Subject: RE: [Fastboot] [PATCH]IA64 kexec/kdump patch for INIT
Message-Id: <83C6D22CB091C5indou.takao@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <82C6D21B8B7A9Cindou.takao@jp.fujitsu.com>
In-Reply-To: <82C6D21B8B7A9Cindou.takao@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Thu, 7 Sep 2006 09:32:38 +0800, "Zou, Nanhai" wrote:

>> On Thu, 7 Sep 2006 08:57:13 +0800, "Zou, Nanhai" wrote:
>>=20
>> >> On Wed, 06 Sep 2006 18:06:53 +0900, Takao Indoh wrote:
>> >>
>> >> >>>+		/* change region of gp to region5 */
>> >> >>>+		asm volatile ("movl gp=3D__gp"::: "memory");
>> >> >>
>> >> >>Why?  gp is already pointing at the kernel code before we enter
>> >> >>ia64_init_handler().
>> >> >
>> >> >The purpose of this code is just changing region of gp from region7 =
to
>> >> >region5. For example, if gp is e000000004ace170, I want to change gp=
 to
>> >>                                 ~~~~~~~~~~~~~~~~e000000000ace170
>> >> Sorry, I mistook address...
>> >>
>> >>
>> >> Regards,
>> >> Takao Indoh
>> >>
>> >  You don't need to set gp here. Control page does not use GP, and
>> >purgatory code will set GP to a physical address which was pre-calculat=
ed
>> >at the time of crash kernel loading.
>>=20
>> If gp points region7, panic occurs at kdump_disable_iosapic.
>>=20
>> kdump_disable_iosapic(void)
>> {
>> 	u32 low32;
>> 	struct iosapic_intr_info *info;
>> 	struct iosapic_rte_info *rte;
>> 	for (info =3D iosapic_intr_info; info <
>> 			iosapic_intr_info + IA64_NUM_VECTORS; ++info) {
>> 		low32 =3D info->low32 |=3D IOSAPIC_MASK;
>> 		list_for_each_entry(rte, &info->rtes,
>> 				rte_list) {
>> (snip)
>>=20
>> The panic occurs at list_for_each_entry. When I found this problem,
>> &info->rtes and rte->rte_list pointed same data but they had different
>> address.
>>=20
>> &info->rtes   =3D> 0xe0000000049231e0
>> rte->rte_list =3D> 0xa0000001009231e0
>>=20
>> info->rtes points region7 because its address is calculated from gp.
>> This difference of address caused panic.
>>=20
>> Regards,
>> Takao Indoh
>>
>
>  Ok, ia64_setreg should be better.
>We should avoid put inline asm code in C file.

Yes, at first I used ia64_setreg, but this problem was not solved.

	if (sos->rv_rc !=3D 1 && (kdump_send_ipi || kdump_on_init)) {
		extern char __gp[];
		local_irq_disable();
		set_curr_task(cpu, previous_current);

		/* change region of gp to region5 */
		ia64_setreg(_IA64_REG_GP, __gp);
		crash_kexec(regs);


The disassemble code:
a000000100047080:       0b 38 01 02 00 24       [MMI]       addl r39=3D0,r1=
;;
a000000100047086:       50 02 9c 00 42 00                   mov r37=3Dr39
a00000010004708c:       00 00 04 00                         nop.i 0x0;;
a000000100047090:       0a 08 00 4a 00 21       [MMI]       mov r1=3Dr37;;
a000000100047096:       c0 02 80 00 42 00                   mov r44=3Dr32
a00000010004709c:       00 00 04 00                         nop.i 0x0
a0000001000470a0:       17 00 02 51 02 14       [BBB]       br.call.sptk.ma=
ny b0=A0000001000db4a0 <crash_kexec>

This disassembled code does not change content of r1.
Am I missing something?

Regards,
Takao Indoh


