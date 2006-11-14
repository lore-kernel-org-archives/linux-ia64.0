From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Tue, 14 Nov 2006 01:11:44 +0000
Subject: RE: 'kexec -l' problem at IA64 SN
Message-Id: <10EA09EFD8728347A513008B6B0DA77A086B1F@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <45591464.5050206@sgi.com>
In-Reply-To: <45591464.5050206@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org
> [mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Jay Lan
> Sent: 2006=C4=EA11=D4=C214=C8=D5 8:57
> To: fastboot
> Cc: Linux-IA64
> Subject: 'kexec -l' problem at IA64 SN
>=20
> Hi,
>=20
> I finally got time to work on 'kexec -l' problem at SGI box.
> The 'kexec -l' always failed on "Invalid memory segment".
> I am using these patches:
>   kexec-tools-1.101-kdump10.patch
>   kexec-tools-1.101-ia64-kdump10-efi-boot.patch
>   clone-ia64_boot_param-kdump10.patch
>   fix-paddr-vmcore-ELF
>   kexec-ia64-reset-vga (a special workaround from Nanhai to
>                         handle vga i/o issue)
> Note that 'kexec -p' worked fine for me.
>=20
> It would try to add memory segment 0x4000000 - 0x4997fff,
> but failed in valid_memory_range() check.
>=20
> It was the first segment it tried to load.
>=20
> The kexec_info struct showed:
> (gdb) p *(struct kexec_info *)0x607fffffffa0b338
> $2 =3D {segment =3D 0x0, nr_segments =3D 0, entry =3D 0x0, rhdr =3D {ei_c=
lass =3D 0,
>     ei_data =3D 0, e_type =3D 0, e_machine =3D 0, e_version =3D 0, e_flag=
s =3D 0,
>     e_phnum =3D 0, e_shnum =3D 0, e_shstrndx =3D 0, e_entry =3D 0, e_phof=
f =3D 0,
>     e_shoff =3D 0, e_notenum =3D 0, e_phdr =3D 0x0, e_shdr =3D 0x0, e_not=
e =3D 0x0,
>     rel_addr =3D 0, rel_size =3D 0}, backup_start =3D 0, kexec_flags =3D =
0}
>=20
>=20
> and, the mem_phdr struct showed:
> (gdb) p *(struct mem_phdr *) 0x6000000000014e20
> $4 =3D {p_paddr =3D 67108864, p_vaddr =3D 11529215050363437056,
>   p_filesz =3D 10000768, p_memsz =3D 10000768, p_offset =3D 65536,
>   p_data =3D 0x2000000000338010 "\004\200", p_type =3D 1, p_flags =3D 7,
>   p_align =3D 65536}
> (gdb)
>=20
> The 'base' variable in elf_exec_load() at the time of calling
> add_segment() was 0.
>=20
> Where did it go wrong? The phdr->p_paddr? The base? It was off
> by 0x3000000000. It needs adjustment, but where in the code and
> which value?
>=20
> The 'kexec -p' worked fine.
>=20
> Thanks,
>  - jay
>=20
>=20
>=20
Hi,
 Kexec -l is still using the entry value of vmlinux while kexec -p can  flo=
at it's loading address according to /proc/iomem.

I will provide a patch to kexec-tools later to fix it.
Thanks
Zou Nan hai
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
