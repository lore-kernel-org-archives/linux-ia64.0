From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Thu, 07 Sep 2006 01:32:38 +0000
Subject: RE: [Fastboot] [PATCH]IA64 kexec/kdump patch for INIT
Message-Id: <08B1877B2880CE42811294894F33AD5C053BF6@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <82C6D21B8B7A9Cindou.takao@jp.fujitsu.com>
In-Reply-To: <82C6D21B8B7A9Cindou.takao@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org
> [mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Takao Indoh
> Sent: 2006=C4=EA9=D4=C27=C8=D5 9:19
> To: Zou, Nanhai
> Cc: Takao Indoh; Keith Owens; linux-ia64@vger.kernel.org;
> fastboot@lists.osdl.org
> Subject: Re: [Fastboot] [PATCH]IA64 kexec/kdump patch for INIT
>=20
> On Thu, 7 Sep 2006 08:57:13 +0800, "Zou, Nanhai" wrote:
>=20
> >> On Wed, 06 Sep 2006 18:06:53 +0900, Takao Indoh wrote:
> >>
> >> >>>+		/* change region of gp to region5 */
> >> >>>+		asm volatile ("movl gp=3D__gp"::: "memory");
> >> >>
> >> >>Why?  gp is already pointing at the kernel code before we enter
> >> >>ia64_init_handler().
> >> >
> >> >The purpose of this code is just changing region of gp from region7 to
> >> >region5. For example, if gp is e000000004ace170, I want to change gp =
to
> >>                                 ~~~~~~~~~~~~~~~~e000000000ace170
> >> Sorry, I mistook address...
> >>
> >>
> >> Regards,
> >> Takao Indoh
> >>
> >  You don't need to set gp here. Control page does not use GP, and
> >purgatory code will set GP to a physical address which was pre-calculated
> >at the time of crash kernel loading.
>=20
> If gp points region7, panic occurs at kdump_disable_iosapic.
>=20
> kdump_disable_iosapic(void)
> {
> 	u32 low32;
> 	struct iosapic_intr_info *info;
> 	struct iosapic_rte_info *rte;
> 	for (info =3D iosapic_intr_info; info <
> 			iosapic_intr_info + IA64_NUM_VECTORS; ++info) {
> 		low32 =3D info->low32 |=3D IOSAPIC_MASK;
> 		list_for_each_entry(rte, &info->rtes,
> 				rte_list) {
> (snip)
>=20
> The panic occurs at list_for_each_entry. When I found this problem,
> &info->rtes and rte->rte_list pointed same data but they had different
> address.
>=20
> &info->rtes   =3D> 0xe0000000049231e0
> rte->rte_list =3D> 0xa0000001009231e0
>=20
> info->rtes points region7 because its address is calculated from gp.
> This difference of address caused panic.
>=20
> Regards,
> Takao Indoh
>

  Ok, ia64_setreg should be better.
We should avoid put inline asm code in C file.

  Thanks
  Zou Nan hai
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
