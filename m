From: "Mallick, Asit K" <asit.k.mallick@intel.com>
Date: Tue, 06 Mar 2001 18:49:42 +0000
Subject: RE: [Linux-ia64] ACPI problems in 2.4.2-ia64-010228
Message-Id: <marc-linux-ia64-105590693005248@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005246@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005246@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Looks like the FW is build 70 and was built on 8/15. Do you see this problem
with newer version of the FW also? We will look into this problem.

Thanks,
Asit


> -----Original Message-----
> From: Keith Owens [mailto:kaos@melbourne.sgi.com]
> Sent: Monday, March 05, 2001 5:31 PM
> To: davidm@hpl.hp.com
> Cc: Grover, Andrew; linux-ia64@linuxia64.org
> Subject: [Linux-ia64] ACPI problems in 2.4.2-ia64-010228
>=20
>=20
> BugSur 2 B1 cpus.  PAL 2213, BIOS W460GXBS2.86E.0070.B.200008150911.
> Kernel 2.4.2 + ia64-010228.  I am getting semi-random data in the acpi
> tables which more often than not will hang the machine during boot.
>=20
> Linux version 2.4.2-ia64-010228-kdb=20
> (kaos@sherman.melbourne.sgi.com) (gcc version=20
> 2.96-ia64-000717 snap 001117) #17 SMP Tue Mar 6 11:28:03 EST 2001
> Warning: EFI system table major version mismatch: got 0.99,=20
> expected 1.00
> EFI v0.99 by INTEL: SALsystab=3D0x3ff23a80 ACPI=3D0x3ffd9be0=20
> MPS=3D0x3ffd0000 SMBIOS=3D0xf0020
> CPU 0: mapping PAL code [0x3ff40000-0x3ff7a000) into=20
> [0xe000000030000000-0xe000000040000000)
> SAL v2.90: oem=3DINTEL   MSL     REF     SAL     , product=3D
> sal[0] - entry: pal_proc=3D0x3ff48010, sal_proc=3D0x3fe4bd70
> SAL: Platform features BusLock=20
> sal[27] - wakeup type 0, 0xf0
> SAL: AP wakeup using external interrupt vector 0xf0
> CPU 0: 51 virtual and 44 physical address bits
> ACPI: Intel    RSDT   0.0
> Acpi cfg:bind to Boot time Acpi OSD
> Acpi cfg:initializ_subsysteme pass
> Acpi cfg:load firmware tables pass
> ACPI: install SCI 32 handler pass
> Acpi cfg:enable_subsystem pass
>       CPU 0 (0000:0000): Available.
>       CPU 1 (0000:0003): Available.
> Acpi Cfg: _PRT found. Need 336 bytes
> Acpi cfg:path=3D[\_SB_.PCI0]
> Acpi cfg:_BBN busnum is 0
>  Acpi cfg:no _STA: pci bus 0 exist
> KAO acpi_cf_add_to_pci_routing_tables e000000000013b88
> Acpi Cfg: _PRT found. Need 312 bytes
> Acpi cfg:path=3D[\_SB_.PCI1]
> Acpi cfg:_BBN busnum is 1
>  Acpi cfg:no _STA: pci bus 1 exist
> KAO acpi_cf_add_to_pci_routing_tables e000000000015d88
> Acpi Cfg: _PRT found. Need 216 bytes
> Acpi cfg:path=3D[\_SB_.PCI2]
> Acpi cfg:_BBN busnum is 2
>  Acpi cfg:_STA: pci bus 2 exist
> KAO acpi_cf_add_to_pci_routing_tables e000000000017488
> Acpi Cfg: _PRT found. Need 48 bytes
> Acpi cfg:path=3D[\_SB_.PCI3]
> Acpi cfg:_BBN busnum is 3
>  Acpi cfg:no _STA: pci bus 3 exist
>=20
> On a clean boot, the first acpi table looks like this, note=20
> the zero at
> 0xe000000000013cd8.
>=20
> [0]kdb> md e000000000013b88
> 0xe000000000013b88 00000018 00000000 0004ffff 00000000=09
> ........=FF=FF......
> 0xe000000000013b98 0000002d 00000000 00000018 00000000=09
> -...............
> 0xe000000000013ba8 0005ffff 00000000 0000002c 00000000=09
> =FF=FF......,.......
> 0xe000000000013bb8 00000018 00000000 0001ffff 00000000=09
> ........=FF=FF......
> 0xe000000000013bc8 00000023 00000000 00000018 00000001=09
> #...............
> 0xe000000000013bd8 0001ffff 00000000 00000022 00000000=09
> =FF=FF......".......
> 0xe000000000013be8 00000018 00000002 0001ffff 00000000=09
> ........=FF=FF......
> 0xe000000000013bf8 00000021 00000000 00000018 00000003=09
> !...............
> 0xe000000000013c08 0001ffff 00000000 00000020 00000000=09
> =FF=FF...... .......
> 0xe000000000013c18 00000018 00000000 0002ffff 00000000=09
> ........=FF=FF......
> 0xe000000000013c28 00000027 00000000 00000018 00000001=09
> '...............
> 0xe000000000013c38 0002ffff 00000000 00000026 00000000=09
> =FF=FF......&.......
> 0xe000000000013c48 00000018 00000002 0002ffff 00000000=09
> ........=FF=FF......
> 0xe000000000013c58 00000025 00000000 00000018 00000003=09
> %...............
> 0xe000000000013c68 0002ffff 00000000 00000024 00000000=09
> =FF=FF......$.......
> 0xe000000000013c78 00000018 00000000 0003ffff 00000000=09
> ........=FF=FF......
> 0xe000000000013c88 0000002e 00000000 00000018 00000001=09
> ................
> 0xe000000000013c98 0003ffff 00000000 0000002e 00000000=09
> =FF=FF..............
> 0xe000000000013ca8 00000018 00000002 0003ffff 00000000=09
> ........=FF=FF......
> 0xe000000000013cb8 0000002f 00000000 00000018 00000003=09
> /...............
> 0xe000000000013cc8 0003ffff 00000000 0000002f 00000000=09
> =FF=FF....../.......
> 0xe000000000013cd8 00000000 00000000 00000000 00000000=09
> ................
> 0xe000000000013ce8 00000000 00000000 00000000 00000000=09
> ................
> 0xe000000000013cf8 00000000 00000000 00000010 00000000=09
> ................
>=20
> On a failing boot, the first acpi table looks like this. =20
> 0xe000000000013cd8
> contains 000000ee which sends acpi_cf_convert_prt_to_vectors=20
> off to the
> wrong location, gets unaligned accesses and more often than not will
> hang the machine.
>=20
> [0]kdb> md e000000000013b88
> 0xe000000000013b88 00000018 00000000 0004ffff 00000000=09
> ........=FF=FF......
> 0xe000000000013b98 0000002d 00000000 00000018 00000000=09
> -...............
> 0xe000000000013ba8 0005ffff 00000000 0000002c 00000000=09
> =FF=FF......,.......
> 0xe000000000013bb8 00000018 00000000 0001ffff 00000000=09
> ........=FF=FF......
> 0xe000000000013bc8 00000023 00000000 00000018 00000001=09
> #...............
> 0xe000000000013bd8 0001ffff 00000000 00000022 00000000=09
> =FF=FF......".......
> 0xe000000000013be8 00000018 00000002 0001ffff 00000000=09
> ........=FF=FF......
> 0xe000000000013bf8 00000021 00000000 00000018 00000003=09
> !...............
> 0xe000000000013c08 0001ffff 00000000 00000020 00000000=09
> =FF=FF...... .......
> 0xe000000000013c18 00000018 00000000 0002ffff 00000000=09
> ........=FF=FF......
> 0xe000000000013c28 00000027 00000000 00000018 00000001=09
> '...............
> 0xe000000000013c38 0002ffff 00000000 00000026 00000000=09
> =FF=FF......&.......
> 0xe000000000013c48 00000018 00000002 0002ffff 00000000=09
> ........=FF=FF......
> 0xe000000000013c58 00000025 00000000 00000018 00000003=09
> %...............
> 0xe000000000013c68 0002ffff 00000000 00000024 00000000=09
> =FF=FF......$.......
> 0xe000000000013c78 00000018 00000000 0003ffff 00000000=09
> ........=FF=FF......
> 0xe000000000013c88 0000002e 00000000 00000018 00000001=09
> ................
> 0xe000000000013c98 0003ffff 00000000 0000002e 00000000=09
> =FF=FF..............
> 0xe000000000013ca8 00000018 00000002 0003ffff 00000000=09
> ........=FF=FF......
> 0xe000000000013cb8 0000002f 00000000 00000018 00000003=09
> /...............
> 0xe000000000013cc8 0003ffff 00000000 0000002f 00000000=09
> =FF=FF....../.......
> 0xe000000000013cd8 000000ee 00000000 00000000 00000000=09
> =EE...............
> 0xe000000000013ce8 00000000 00000000 0001d1d1 00000000=09
> ........=D1=D1......
> 0xe000000000013cf8 000100ee 00000000 00000010 00000000=09
> =EE...............
>=20
> Since we know the table size (Acpi Cfg: _PRT found. Need 336 bytes)
> should acpi use the table size instead of looking for a zero length?
>=20
> 2.4.1-ia64-010131 with the same config and compiler works fine on this
> machine.  It may not be relevant but even when 2.4.2 boots past the
> acpi problem, /sbin/init spins in user space.  No idea why yet, it is
> very rare that I can get past acpi.
>=20
>=20
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
>=20


