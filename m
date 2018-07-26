From: Alex Ghiti <alex@ghiti.fr>
Date: Thu, 26 Jul 2018 16:46:20 +0000
Subject: Re: [PATCH v4 00/11] hugetlb: Factorize hugetlb architecture primitives
Message-Id: <58887adf-1852-4291-08aa-a1dd2007326b@ghiti.fr>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180705110716.3919-1-alex@ghiti.fr>
 <20180709141621.GD22297@dhcp22.suse.cz>
 <2173685f-7f85-7acb-4685-2383210c5fa2@ghiti.fr>
 <87d0vehx16.fsf@concordia.ellerman.id.au>
 <67aba0f0-c0d4-b06f-5fbc-f4d113ce5033@ghiti.fr>
 <20180726171355.Horde.KlFUG9wXmbRDCiyhk5bHsw8@messagerie.si.c-s.fr>
In-Reply-To: <20180726171355.Horde.KlFUG9wXmbRDCiyhk5bHsw8@messagerie.si.c-s.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: LEROY Christophe <christophe.leroy@c-s.fr>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, davem@davemloft.net, linuxppc-dev@lists.ozlabs.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, paul.burton@mips.com, ralf@linux-mips.org, linux-kernel@vger.kernel.org, linux-parisc@vger.kernel.org, tony.luck@intel.com, linux-arm-kernel@lists.infradead.org, tglx@linutronix.de, arnd@arndb.de, fenghua.yu@intel.com, jhogan@kernel.org, catalin.marinas@arm.com, mingo@redhat.com, linux@armlinux.org.uk, x86@kernel.org, deller@gmx.de, ysato@users.sourceforge.jp, linux-arch@vger.kernel.org, sparclinux@vger.kernel.org, hpa@zytor.com, paulus@samba.org, jejb@parisc-linux.org, will.deacon@arm.com, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, dalias@libc.org, linux-mips@linux-mips.org, Michal Hocko <mhocko@kernel.org>, Michael

Hi Christophe,

Sorry, I should have done it already: with and without huge page 
activated, the build for mpc885_ads_defconfig is OK.

Thanks,

Alex

On 07/26/2018 03:13 PM, LEROY Christophe wrote:
> Alex Ghiti <alex@ghiti.fr> a écrit :
>
>> Hi everyone,
>>
>> This is the result of the build for all arches tackled in this series 
>> rebased on 4.18-rc6:
>>
>> arm:
>>         versatile_defconfig: without huge page OK
>>         keystone_defconfig: with huge page OK
>> arm64:
>>         defconfig: with huge page OK
>> ia64:
>>         generic_defconfig: with huge page OK
>> mips:
>>         Paul Burton tested cavium octeon with huge page OK
>> parisc:
>>         generic-64bit_defconfig: with huge page does not link
>>         generic-64bit_defconfig: without huge page does not link
>>         BUT not because of this series, any feedback welcome.
>> powerpc:
>>         ppc64_defconfig: without huge page OK
>>         ppc64_defconfig: with huge page OK
>
> Can you also test ppc32 both with and without hugepage 
> (mpc885_ads_defconfig)
>
> Thanks
> Christophe
>
>> sh:
>>         dreamcast_defconfig: with huge page OK
>> sparc:
>>         sparc32_defconfig: without huge page OK
>> sparc64:
>>         sparc64_defconfig: with huge page OK
>> x86:
>>         with huge page OK
>>
>> Alex
>>
>> On 07/23/2018 02:00 PM, Michael Ellerman wrote:
>>> Alex Ghiti <alex@ghiti.fr> writes:
>>>
>>>> Does anyone have any suggestion about those patches ?
>>> Cross compiling it for some non-x86 arches would be a good start :)
>>>
>>> There are cross compilers available here:
>>>
>>>   https://mirrors.edge.kernel.org/pub/tools/crosstool/
>>>
>>>
>>> cheers
>>>
>>>> On 07/09/2018 02:16 PM, Michal Hocko wrote:
>>>>> [CC hugetlb guys - 
>>>>> http://lkml.kernel.org/r/20180705110716.3919-1-alex@ghiti.fr]
>>>>>
>>>>> On Thu 05-07-18 11:07:05, Alexandre Ghiti wrote:
>>>>>> In order to reduce copy/paste of functions across architectures 
>>>>>> and then
>>>>>> make riscv hugetlb port (and future ports) simpler and smaller, this
>>>>>> patchset intends to factorize the numerous hugetlb primitives 
>>>>>> that are
>>>>>> defined across all the architectures.
>>>>>>
>>>>>> Except for prepare_hugepage_range, this patchset moves the 
>>>>>> versions that
>>>>>> are just pass-through to standard pte primitives into
>>>>>> asm-generic/hugetlb.h by using the same #ifdef semantic that can be
>>>>>> found in asm-generic/pgtable.h, i.e. __HAVE_ARCH_***.
>>>>>>
>>>>>> s390 architecture has not been tackled in this serie since it 
>>>>>> does not
>>>>>> use asm-generic/hugetlb.h at all.
>>>>>> powerpc could be factorized a bit more (cf huge_ptep_set_wrprotect).
>>>>>>
>>>>>> This patchset has been compiled on x86 only.
>>>>>>
>>>>>> Changelog:
>>>>>>
>>>>>> v4:
>>>>>>    Fix powerpc build error due to misplacing of #include
>>>>>>    <asm-generic/hugetlb.h> outside of #ifdef CONFIG_HUGETLB_PAGE, as
>>>>>>    pointed by Christophe Leroy.
>>>>>>
>>>>>> v1, v2, v3:
>>>>>>    Same version, just problems with email provider and misuse of
>>>>>>    --batch-size option of git send-email
>>>>>>
>>>>>> Alexandre Ghiti (11):
>>>>>>    hugetlb: Harmonize hugetlb.h arch specific defines with pgtable.h
>>>>>>    hugetlb: Introduce generic version of hugetlb_free_pgd_range
>>>>>>    hugetlb: Introduce generic version of set_huge_pte_at
>>>>>>    hugetlb: Introduce generic version of huge_ptep_get_and_clear
>>>>>>    hugetlb: Introduce generic version of huge_ptep_clear_flush
>>>>>>    hugetlb: Introduce generic version of huge_pte_none
>>>>>>    hugetlb: Introduce generic version of huge_pte_wrprotect
>>>>>>    hugetlb: Introduce generic version of prepare_hugepage_range
>>>>>>    hugetlb: Introduce generic version of huge_ptep_set_wrprotect
>>>>>>    hugetlb: Introduce generic version of huge_ptep_set_access_flags
>>>>>>    hugetlb: Introduce generic version of huge_ptep_get
>>>>>>
>>>>>>   arch/arm/include/asm/hugetlb-3level.h        | 32 +---------
>>>>>>   arch/arm/include/asm/hugetlb.h               | 33 +----------
>>>>>>   arch/arm64/include/asm/hugetlb.h             | 39 +++---------
>>>>>>   arch/ia64/include/asm/hugetlb.h              | 47 ++-------------
>>>>>>   arch/mips/include/asm/hugetlb.h              | 40 +++----------
>>>>>>   arch/parisc/include/asm/hugetlb.h            | 33 +++--------
>>>>>>   arch/powerpc/include/asm/book3s/32/pgtable.h |  2 +
>>>>>>   arch/powerpc/include/asm/book3s/64/pgtable.h |  1 +
>>>>>>   arch/powerpc/include/asm/hugetlb.h           | 43 ++------------
>>>>>>   arch/powerpc/include/asm/nohash/32/pgtable.h |  2 +
>>>>>>   arch/powerpc/include/asm/nohash/64/pgtable.h |  1 +
>>>>>>   arch/sh/include/asm/hugetlb.h                | 54 
>>>>>> ++---------------
>>>>>>   arch/sparc/include/asm/hugetlb.h             | 40 +++----------
>>>>>>   arch/x86/include/asm/hugetlb.h               | 72 
>>>>>> +----------------------
>>>>>>   include/asm-generic/hugetlb.h                | 88 
>>>>>> +++++++++++++++++++++++++++-
>>>>>>   15 files changed, 143 insertions(+), 384 deletions(-)
>>>>>>
>>>>>> -- 
>>>>>> 2.16.2
>
>

