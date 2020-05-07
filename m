From: Mike Rapoport <rppt@linux.ibm.com>
Date: Thu, 07 May 2020 16:11:55 +0000
Subject: Re: [PATCH v4 02/14] arm: add support for folded p4d page tables
Message-Id: <20200507161155.GE683243@linux.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200414153455.21744-1-rppt@kernel.org>
 <20200414153455.21744-3-rppt@kernel.org>
 <CGME20200507121658eucas1p240cf4a3e0fe5c22dda5ec4f72734149f@eucas1p2.samsung.com>
 <39ba8a04-d6b5-649d-c289-0c8b27cb66c5@samsung.com>
In-Reply-To: <39ba8a04-d6b5-649d-c289-0c8b27cb66c5@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, Geert Uytterhoeven <geert+renesas@glider.be>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Will Deacon <will@kernel.org>, kvmarm@lists.cs.columbia.edu, Jonas Bonn <jonas@southpole.se>, Brian Cain <bcain@codeaurora.org>, linux-hexagon@vger.kernel.org, linux-sh@vger.kernel.org, Russell King <linux@armlinux.org.uk>, Ley Foon Tan <ley.foon.tan@intel.com>, Catalin Marinas <catalin.marinas@arm.com>, uclinux-h8-devel@lists.sourceforge.jp, linux-arch@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, =?utf-8?Q?=C5=81ukasz?= Stelmach <l.stelmach@samsung.com>, kvm-ppc@vger.kernel.org, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, openrisc@lists.librecores.org, Stafford Horne <shorne@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, linux-arm-kernel@lists.infradead.org, Christophe Leroy <christophe.leroy@c-s.fr>, Tony Luck <tony.luck@intel.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-kernel@vger.kernel.org, Marc Zyngier <maz@kernel.org>, nios2-dev@lists.rocketboards.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, Mike Rapoport <rppt@kernel.org>

Hi,

On Thu, May 07, 2020 at 02:16:56PM +0200, Marek Szyprowski wrote:
> Hi
>=20
> On 14.04.2020 17:34, Mike Rapoport wrote:
> > From: Mike Rapoport <rppt@linux.ibm.com>
> >
> > Implement primitives necessary for the 4th level folding, add walks of =
p4d
> > level where appropriate, and remove __ARCH_USE_5LEVEL_HACK.
> >
> > Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
>=20
> Today I've noticed that kexec is broken on ARM 32bit. Bisecting between=20
> current linux-next and v5.7-rc1 pointed to this commit. I've tested this =

> on Odroid XU4 and Raspberry Pi4 boards. Here is the relevant log:
>=20
> # kexec --kexec-syscall -l zImage --append "$(cat /proc/cmdline)"
> memory_range[0]:0x40000000..0xbe9fffff
> memory_range[0]:0x40000000..0xbe9fffff
> # kexec -e
> kexec_core: Starting new kernel
> 8<--- cut here ---
> Unable to handle kernel paging request at virtual address c010f1f4
> pgd =3D c6817793
> [c010f1f4] *pgd@00041e(bad)
> Internal error: Oops: 80d [#1] PREEMPT ARM
> Modules linked in:
> CPU: 0 PID: 1329 Comm: kexec Tainted: G=A0=A0=A0=A0=A0=A0=A0 W=20
> 5.7.0-rc3-00127-g6cba81ed0f62 #611
> Hardware name: Samsung Exynos (Flattened Device Tree)
> PC is at machine_kexec+0x40/0xfc

Any chance you have the debug info in this kernel?
scripts/faddr2line would come handy here.

> LR is at 0xffffffff
> pc : [<c010f0b4>]=A0=A0=A0 lr : [<ffffffff>]=A0=A0=A0 psr: 60000013
> sp : ebc13e60=A0 ip : 40008000=A0 fp : 00000001
> r10: 00000058=A0 r9 : fee1dead=A0 r8 : 00000001
> r7 : c121387c=A0 r6 : 6c224000=A0 r5 : ece40c00=A0 r4 : ec222000
> r3 : c010f1f4=A0 r2 : c1100000=A0 r1 : c1100000=A0 r0 : 418d0000
> Flags: nZCv=A0 IRQs on=A0 FIQs on=A0 Mode SVC_32=A0 ISA ARM=A0 Segment no=
ne
> Control: 10c5387d=A0 Table: 6bc14059=A0 DAC: 00000051
> Process kexec (pid: 1329, stack limit =3D 0x366bb4dc)
> Stack: (0xebc13e60 to 0xebc14000)
> ...
> [<c010f0b4>] (machine_kexec) from [<c01c0d84>] (kernel_kexec+0x74/0x7c)
> [<c01c0d84>] (kernel_kexec) from [<c014b1bc>] (__do_sys_reboot+0x1f8/0x21=
0)
> [<c014b1bc>] (__do_sys_reboot) from [<c0100060>] (ret_fast_syscall+0x0/0x=
28)
> Exception stack(0xebc13fa8 to 0xebc13ff0)
> ...
> ---[ end trace 3e8d6c81723c778d ]---
> 1329 Segmentation fault=A0=A0=A0=A0=A0 ./kexec -e
>=20
> > ---
> >   arch/arm/include/asm/pgtable.h     |  1 -
> >   arch/arm/lib/uaccess_with_memcpy.c |  7 +++++-
> >   arch/arm/mach-sa1100/assabet.c     |  2 +-
> >   arch/arm/mm/dump.c                 | 29 +++++++++++++++++-----
> >   arch/arm/mm/fault-armv.c           |  7 +++++-
> >   arch/arm/mm/fault.c                | 22 ++++++++++------
> >   arch/arm/mm/idmap.c                |  3 ++-
> >   arch/arm/mm/init.c                 |  2 +-
> >   arch/arm/mm/ioremap.c              | 12 ++++++---
> >   arch/arm/mm/mm.h                   |  2 +-
> >   arch/arm/mm/mmu.c                  | 35 +++++++++++++++++++++-----
> >   arch/arm/mm/pgd.c                  | 40 ++++++++++++++++++++++++------
> >   12 files changed, 125 insertions(+), 37 deletions(-)
> >
> > ...
>=20
> Best regards
> --=20
> Marek Szyprowski, PhD
> Samsung R&D Institute Poland
>=20

--=20
Sincerely yours,
Mike.
