From: Mike Kravetz <mike.kravetz@oracle.com>
Date: Sat, 21 Jul 2018 00:24:12 +0000
Subject: Re: [PATCH v4 00/11] hugetlb: Factorize hugetlb architecture primitives
Message-Id: <75195a7d-3d0f-4e55-92cc-4ad772683c75@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180705110716.3919-1-alex@ghiti.fr>
 <20180709141621.GD22297@dhcp22.suse.cz>
 <2173685f-7f85-7acb-4685-2383210c5fa2@ghiti.fr>
In-Reply-To: <2173685f-7f85-7acb-4685-2383210c5fa2@ghiti.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Ghiti <alex@ghiti.fr>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mips@linux-mips.org, dalias@libc.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, benh@kernel.crashing.org, will.deacon@arm.com, jejb@parisc-linux.org, paulus@samba.org, hpa@zytor.com, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, ysato@users.sourceforge.jp, mpe@ellerman.id.au, deller@gmx.de, x86@kernel.org, linux@armlinux.org.uk, mingo@redhat.com, catalin.marinas@arm.com, jhogan@kernel.org, fenghua.yu@intel.com, arnd@arndb.de, tglx@linutronix.de, linux-arm-kernel@lists.infradead.org, tony.luck@intel.com, linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org, ralf@linux-mips.org, paul.burton@mips.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net

On 07/20/2018 11:37 AM, Alex Ghiti wrote:
> Does anyone have any suggestion about those patches ?

I only took a quick look.  From the hugetlb perspective, I like the
idea of moving routines to a common file.  If any of the arch owners
(or anyone else) agree, I can do a review of the series.
-- 
Mike Kravetz

> On 07/09/2018 02:16 PM, Michal Hocko wrote:
>> [CC hugetlb guys - http://lkml.kernel.org/r/20180705110716.3919-1-alex@ghiti.fr]
>>
>> On Thu 05-07-18 11:07:05, Alexandre Ghiti wrote:
>>> In order to reduce copy/paste of functions across architectures and then
>>> make riscv hugetlb port (and future ports) simpler and smaller, this
>>> patchset intends to factorize the numerous hugetlb primitives that are
>>> defined across all the architectures.
>>>
>>> Except for prepare_hugepage_range, this patchset moves the versions that
>>> are just pass-through to standard pte primitives into
>>> asm-generic/hugetlb.h by using the same #ifdef semantic that can be
>>> found in asm-generic/pgtable.h, i.e. __HAVE_ARCH_***.
>>>
>>> s390 architecture has not been tackled in this serie since it does not
>>> use asm-generic/hugetlb.h at all.
>>> powerpc could be factorized a bit more (cf huge_ptep_set_wrprotect).
>>>
>>> This patchset has been compiled on x86 only.
>>>
>>> Changelog:
>>>
>>> v4:
>>>    Fix powerpc build error due to misplacing of #include
>>>    <asm-generic/hugetlb.h> outside of #ifdef CONFIG_HUGETLB_PAGE, as
>>>    pointed by Christophe Leroy.
>>>
>>> v1, v2, v3:
>>>    Same version, just problems with email provider and misuse of
>>>    --batch-size option of git send-email
>>>
>>> Alexandre Ghiti (11):
>>>    hugetlb: Harmonize hugetlb.h arch specific defines with pgtable.h
>>>    hugetlb: Introduce generic version of hugetlb_free_pgd_range
>>>    hugetlb: Introduce generic version of set_huge_pte_at
>>>    hugetlb: Introduce generic version of huge_ptep_get_and_clear
>>>    hugetlb: Introduce generic version of huge_ptep_clear_flush
>>>    hugetlb: Introduce generic version of huge_pte_none
>>>    hugetlb: Introduce generic version of huge_pte_wrprotect
>>>    hugetlb: Introduce generic version of prepare_hugepage_range
>>>    hugetlb: Introduce generic version of huge_ptep_set_wrprotect
>>>    hugetlb: Introduce generic version of huge_ptep_set_access_flags
>>>    hugetlb: Introduce generic version of huge_ptep_get
>>>
>>>   arch/arm/include/asm/hugetlb-3level.h        | 32 +---------
>>>   arch/arm/include/asm/hugetlb.h               | 33 +----------
>>>   arch/arm64/include/asm/hugetlb.h             | 39 +++---------
>>>   arch/ia64/include/asm/hugetlb.h              | 47 ++-------------
>>>   arch/mips/include/asm/hugetlb.h              | 40 +++----------
>>>   arch/parisc/include/asm/hugetlb.h            | 33 +++--------
>>>   arch/powerpc/include/asm/book3s/32/pgtable.h |  2 +
>>>   arch/powerpc/include/asm/book3s/64/pgtable.h |  1 +
>>>   arch/powerpc/include/asm/hugetlb.h           | 43 ++------------
>>>   arch/powerpc/include/asm/nohash/32/pgtable.h |  2 +
>>>   arch/powerpc/include/asm/nohash/64/pgtable.h |  1 +
>>>   arch/sh/include/asm/hugetlb.h                | 54 ++---------------
>>>   arch/sparc/include/asm/hugetlb.h             | 40 +++----------
>>>   arch/x86/include/asm/hugetlb.h               | 72 +----------------------
>>>   include/asm-generic/hugetlb.h                | 88 +++++++++++++++++++++++++++-
>>>   15 files changed, 143 insertions(+), 384 deletions(-)
>>>
>>> -- 
>>> 2.16.2
> 
