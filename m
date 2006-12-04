From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Mon, 04 Dec 2006 01:10:16 +0000
Subject: RE: IA64: kexec seg fault at xrealloc
Message-Id: <10EA09EFD8728347A513008B6B0DA77A086B44@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4570C0EF.2090609@sgi.com>
In-Reply-To: <4570C0EF.2090609@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Can you try enlarging MAX_LOAD_SEGMENTS in crashdump-ia64.c?

Thanks=20
Zou Nan hai

> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org
> [mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Jay Lan
> Sent: 2006=C4=EA12=D4=C22=C8=D5 7:55
> To: fastboot
> Cc: Linux-IA64
> Subject: IA64: kexec seg fault at xrealloc
>=20
> The kexec seg faulted when i ran test at an 56p SN machine.
> It was successful on a 2p SN.
>=20
>=20
> (gdb) bt
> #0  0x200000000016a900 in _int_realloc () from /lib/libc.so.6.1
> #1  0x200000000016e020 in realloc () from /lib/libc.so.6.1
> #2  0x40000000000020c0 in xrealloc (ptr=3D0x600000000002ada0, size=160)
>     at kexec/kexec.c:70
> #3  0x40000000000042a0 in add_segment (info=3D0x60000ffffe2c3718,
>     buf=3D0x600000000002ae30, bufsz=12288, base 6963621888, memsz=16384)
>     at kexec/kexec.c:310
> #4  0x40000000000047f0 in add_buffer (info=3D0x60000ffffe2c3718,
>     buf=3D0x600000000002ae30, bufsz=12288, memsz=16384, buf_align@96,
>     buf_min=3D0, buf_max=18446744073709551615, buf_end=3D-1) at
> kexec/kexec.c:345
> #5  0x400000000001aa20 in load_crashdump_segments (info=3D0x60000ffffe2c3=
718,
>     ehdr=3D0x60000ffffe2c3578, max_addr=18446744073709551615, min_base=3D=
0,
>     cmdline=3D0x60000ffffe2c35e8) at kexec/arch/ia64/crashdump-ia64.c:328
> #6  0x4000000000016970 in elf_ia64_load (argc=3D6, argv=3D0x60000ffffe2c3=
af8,
>     buf=3D0x2000000000324010 "\177ELF\002\001\001", len=15939392,
>     info=3D0x60000ffffe2c3718) at kexec/arch/ia64/kexec-elf-ia64.c:203
> #7  0x4000000000006a00 in my_load (type=3D0x0, fileind=3D5, argc=3D6,
>     argv=3D0x60000ffffe2c3af8, kexec_flags=3D1) at kexec/kexec.c:617
> #8  0x4000000000008220 in main (argc=3D6, argv=3D0x60000ffffe2c3af8)
>     at kexec/kexec.c:859
> (gdb)
>=20
> The add_segment() contains code as below:
>=20
> add_segment()
> {
>         ...
>         last =3D base + memsz -1;
>         if (!valid_memory_range(base, last)) {
>                 die("Invalid memory segment %p - %p\n",
>                         (void *)base, (void *)last);
>         }
>=20
>         size =3D (info->nr_segments + 1) * sizeof(info->segment[0]);
>         info->segment =3D xrealloc(info->segment, size); <=3D=3D=3D seg f=
ault
>         info->segment[info->nr_segments].buf   =3D buf;
>         info->segment[info->nr_segments].bufsz =3D bufsz;
>         info->segment[info->nr_segments].mem   =3D (void *)base;
>         info->segment[info->nr_segments].memsz =3D memsz;
>=20
>         info->nr_segments++;
>         ...
> }
>=20
> The seg fault happened on nr_segment=3D4. At the end of nr_segment=3D3
> info->segment was set to 2ada0 in the statement
>         info->segment =3D xrealloc(info->segment, size);
> And the subsequent call to xrealloc() on nr_segment=3D4, it died.
>=20
> On the 2p machine that was successful, the info->segment was set to
> 29310 at the end of nr_segment=3D3. It went all the way to 30b10 at
> the end of 9th segment. So, the value 2ada0 seems still in the bound.
>=20
> Can anyone more familiar with xrealloc and kexec tell me what might
> cause the seg fault?
>=20
> Thanks,
>  - jay
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
