From: Catalin Marinas <catalin.marinas@arm.com>
Date: Tue, 31 Jul 2018 09:26:34 +0000
Subject: Re: [PATCH v5 00/11] hugetlb: Factorize hugetlb architecture primitives
Message-Id: <20180731092634.m4wpbhyn54r7fxmb@armageddon.cambridge.arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180731060155.16915-1-alex@ghiti.fr>
In-Reply-To: <20180731060155.16915-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alexandre Ghiti <alex@ghiti.fr>
Cc: linux-mm@kvack.org, mike.kravetz@oracle.com, linux@armlinux.org.uk, will.deacon@arm.com, tony.luck@intel.com, fenghua.yu@intel.com, ralf@linux-mips.org, paul.burton@mips.com, jhogan@kernel.org, jejb@parisc-linux.org, deller@gmx.de, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, arnd@arndb.de, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org

On Tue, Jul 31, 2018 at 06:01:44AM +0000, Alexandre Ghiti wrote:
> Alexandre Ghiti (11):
>   hugetlb: Harmonize hugetlb.h arch specific defines with pgtable.h
>   hugetlb: Introduce generic version of hugetlb_free_pgd_range
>   hugetlb: Introduce generic version of set_huge_pte_at
>   hugetlb: Introduce generic version of huge_ptep_get_and_clear
>   hugetlb: Introduce generic version of huge_ptep_clear_flush
>   hugetlb: Introduce generic version of huge_pte_none
>   hugetlb: Introduce generic version of huge_pte_wrprotect
>   hugetlb: Introduce generic version of prepare_hugepage_range
>   hugetlb: Introduce generic version of huge_ptep_set_wrprotect
>   hugetlb: Introduce generic version of huge_ptep_set_access_flags
>   hugetlb: Introduce generic version of huge_ptep_get
[...]
>  arch/arm64/include/asm/hugetlb.h             | 39 +++---------

For the arm64 bits in this series:

Acked-by: Catalin Marinas <catalin.marinas@arm.com>
