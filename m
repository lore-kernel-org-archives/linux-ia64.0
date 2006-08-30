From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Wed, 30 Aug 2006 01:38:47 +0000
Subject: RE: [Fastboot] IA64 Kdump patch V3
Message-Id: <08B1877B2880CE42811294894F33AD5C053BD6@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44F4E94E.8090700@sgi.com>
In-Reply-To: <44F4E94E.8090700@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


> -----Original Message-----
> From: Jay Lan [mailto:jlan@sgi.com]
> Sent: 2006=C4=EA8=D4=C230=C8=D5 9:27
> To: Zou, Nanhai
> Cc: Linux-IA64; fastboot; Luck, Tony; Dave Anderson; Eric W. Biederman; H=
orms
> Subject: Re: [Fastboot] IA64 Kdump patch V3
>=20
> Jay Lan wrote:
> > Hi Nanhai,
> >
> > There is a problem in sn2. The sn2 does not have any memory with
> > a predictible offset. It is not possible to specify a memory location
> > at boot.
> >
> > I modified the efi_initialize_iomem_resources() routine in
> > arch/ia64/kernel/efi.c to calculate crashk_res.start and .end on the
> > fly and uses the "A" of crashkernel=3DA@B as size to find a region
> > that fits.
> >
> > Maybe we should separate A and B as two options?
>=20
> The "B" part of the crashkernel boot option is meaningless to sn2
> machine and can be very confusing to sn2 users.
>

 Hi, Jay
	It is possible to have only A option and let kernel determine the B addres=
s at startup time. Horms has patch to do that, I will merge it.

> >
> > I now have memory reserved, but kernal hanged when executing 'kexec'
> > command. There must be similar issues in kexec.
>=20
> On further debugging, the kexec dumped core instead at this statement:
> +        elf_rel_set_symbol(&info->rhdr, "__boot_param_base",
> +                        &boot_param_base, sizeof(long));
>=20
> of elf_ia64_load() in kexec/arch/ia64/kexec-elf-ia64.c.
>=20
> Examing the memory i found "__boot_param_base" indeed not present in
> the symbol table.
>=20
> It seems that purgatory/arch/ia64/entry.S does not have a line
> +DECLARE_DATAB(____boot_param_base).
> Is it not needed in other ia64 machines? How does it work in HP
> machines?
  There is a DECLARE_DATA8(__boot_param_base) in purgatory/arch/ia64/entry.S
  Are you using kexec-tools-kdump10 patch?
=20
 Thanks
 Zou Nan hai
>=20
> Thanks,
>   - jay
>=20
