From: Alex Ghiti <alex@ghiti.fr>
Date: Thu, 26 Jul 2018 05:41:03 +0000
Subject: Re: [PATCH v4 00/11] hugetlb: Factorize hugetlb architecture primitives
Message-Id: <67aba0f0-c0d4-b06f-5fbc-f4d113ce5033@ghiti.fr>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180705110716.3919-1-alex@ghiti.fr>
 <20180709141621.GD22297@dhcp22.suse.cz>
 <2173685f-7f85-7acb-4685-2383210c5fa2@ghiti.fr>
 <87d0vehx16.fsf@concordia.ellerman.id.au>
In-Reply-To: <87d0vehx16.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@kernel.org>
Cc: linux@armlinux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com, tony.luck@intel.com, fenghua.yu@intel.com, ralf@linux-mips.org, paul.burton@mips.com, jhogan@kernel.org, jejb@parisc-linux.org, deller@gmx.de, benh@kernel.crashing.org, paulus@samba.org, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, arnd@arndb.de, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mike Kravetz <mike.kravetz@oracle.com>

Hi everyone,

This is the result of the build for all arches tackled in this series=20
rebased on 4.18-rc6:

arm:
 =A0=A0=A0=A0=A0=A0=A0 versatile_defconfig: without huge page OK
 =A0=A0=A0=A0=A0=A0=A0 keystone_defconfig: with huge page OK
arm64:
 =A0=A0=A0=A0=A0=A0=A0 defconfig: with huge page OK
ia64:
 =A0=A0=A0=A0=A0=A0=A0 generic_defconfig: with huge page OK
mips:
 =A0=A0=A0=A0=A0=A0=A0 Paul Burton tested cavium octeon with huge page OK
parisc:
 =A0=A0=A0=A0=A0=A0=A0 generic-64bit_defconfig: with huge page does not link
 =A0=A0=A0=A0=A0=A0=A0 generic-64bit_defconfig: without huge page does not =
link
 =A0=A0=A0=A0=A0=A0=A0 BUT not because of this series, any feedback welcome.
powerpc:
 =A0=A0=A0=A0=A0=A0=A0 ppc64_defconfig: without huge page OK
 =A0=A0=A0=A0=A0=A0=A0 ppc64_defconfig: with huge page OK
sh:
 =A0=A0=A0=A0=A0=A0=A0 dreamcast_defconfig: with huge page OK
sparc:
 =A0=A0=A0=A0=A0=A0=A0 sparc32_defconfig: without huge page OK
sparc64:
 =A0=A0=A0=A0=A0=A0=A0 sparc64_defconfig: with huge page OK
x86:
 =A0=A0=A0=A0=A0=A0=A0 with huge page OK

Alex

On 07/23/2018 02:00 PM, Michael Ellerman wrote:
> Alex Ghiti <alex@ghiti.fr> writes:
>
>> Does anyone have any suggestion about those patches ?
> Cross compiling it for some non-x86 arches would be a good start :)
>
> There are cross compilers available here:
>
>    https://mirrors.edge.kernel.org/pub/tools/crosstool/
>
>
> cheers
>
>> On 07/09/2018 02:16 PM, Michal Hocko wrote:
>>> [CC hugetlb guys - http://lkml.kernel.org/r/20180705110716.3919-1-alex@=
ghiti.fr]
>>>
>>> On Thu 05-07-18 11:07:05, Alexandre Ghiti wrote:
>>>> In order to reduce copy/paste of functions across architectures and th=
en
>>>> make riscv hugetlb port (and future ports) simpler and smaller, this
>>>> patchset intends to factorize the numerous hugetlb primitives that are
>>>> defined across all the architectures.
>>>>
>>>> Except for prepare_hugepage_range, this patchset moves the versions th=
at
>>>> are just pass-through to standard pte primitives into
>>>> asm-generic/hugetlb.h by using the same #ifdef semantic that can be
>>>> found in asm-generic/pgtable.h, i.e. __HAVE_ARCH_***.
>>>>
>>>> s390 architecture has not been tackled in this serie since it does not
>>>> use asm-generic/hugetlb.h at all.
>>>> powerpc could be factorized a bit more (cf huge_ptep_set_wrprotect).
>>>>
>>>> This patchset has been compiled on x86 only.
>>>>
>>>> Changelog:
>>>>
>>>> v4:
>>>>     Fix powerpc build error due to misplacing of #include
>>>>     <asm-generic/hugetlb.h> outside of #ifdef CONFIG_HUGETLB_PAGE, as
>>>>     pointed by Christophe Leroy.
>>>>
>>>> v1, v2, v3:
>>>>     Same version, just problems with email provider and misuse of
>>>>     --batch-size option of git send-email
>>>>
>>>> Alexandre Ghiti (11):
>>>>     hugetlb: Harmonize hugetlb.h arch specific defines with pgtable.h
>>>>     hugetlb: Introduce generic version of hugetlb_free_pgd_range
>>>>     hugetlb: Introduce generic version of set_huge_pte_at
>>>>     hugetlb: Introduce generic version of huge_ptep_get_and_clear
>>>>     hugetlb: Introduce generic version of huge_ptep_clear_flush
>>>>     hugetlb: Introduce generic version of huge_pte_none
>>>>     hugetlb: Introduce generic version of huge_pte_wrprotect
>>>>     hugetlb: Introduce generic version of prepare_hugepage_range
>>>>     hugetlb: Introduce generic version of huge_ptep_set_wrprotect
>>>>     hugetlb: Introduce generic version of huge_ptep_set_access_flags
>>>>     hugetlb: Introduce generic version of huge_ptep_get
>>>>
>>>>    arch/arm/include/asm/hugetlb-3level.h        | 32 +---------
>>>>    arch/arm/include/asm/hugetlb.h               | 33 +----------
>>>>    arch/arm64/include/asm/hugetlb.h             | 39 +++---------
>>>>    arch/ia64/include/asm/hugetlb.h              | 47 ++-------------
>>>>    arch/mips/include/asm/hugetlb.h              | 40 +++----------
>>>>    arch/parisc/include/asm/hugetlb.h            | 33 +++--------
>>>>    arch/powerpc/include/asm/book3s/32/pgtable.h |  2 +
>>>>    arch/powerpc/include/asm/book3s/64/pgtable.h |  1 +
>>>>    arch/powerpc/include/asm/hugetlb.h           | 43 ++------------
>>>>    arch/powerpc/include/asm/nohash/32/pgtable.h |  2 +
>>>>    arch/powerpc/include/asm/nohash/64/pgtable.h |  1 +
>>>>    arch/sh/include/asm/hugetlb.h                | 54 ++---------------
>>>>    arch/sparc/include/asm/hugetlb.h             | 40 +++----------
>>>>    arch/x86/include/asm/hugetlb.h               | 72 +----------------=
------
>>>>    include/asm-generic/hugetlb.h                | 88 +++++++++++++++++=
++++++++++-
>>>>    15 files changed, 143 insertions(+), 384 deletions(-)
>>>>
>>>> --=20
>>>> 2.16.2

