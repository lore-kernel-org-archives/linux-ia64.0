From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Tue, 14 Apr 2020 11:56:27 +0000
Subject: [PATCH 0/3] mm/hugetlb: Add some new arch enabling macros
Message-Id: <1586864670-21799-1-git-send-email-anshuman.khandual@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org
Cc: Anshuman Khandual <anshuman.khandual@arm.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <d>

This series adds two macros which platforms can enable to override generic
fallback definitions. Before that it drops __HAVE_ARCH_HUGE_PTEP_GET from
arm64 platform.

1. HAVE_ARCH_IS_HUGEPAGE_ONLY_RANGE - is_hugepage_only_range()
2. HAVE_ARCH_CLEAR_HUGEPAGE_FLAGS   - arch_clear_hugepage_flags()

This has been boot tested on arm64 and x86 platforms but built tested on
some more platforms including the changed ones here. This series applies
on v5.7-rc1. After this arm (32 bit) remains the sole platform defining
it's own huge_ptep_get() via __HAVE_ARCH_HUGE_PTEP_GET.

Cc: Russell King <linux@armlinux.org.uk>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will@kernel.org>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Cc: "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>
Cc: Helge Deller <deller@gmx.de>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Paul Walmsley <paul.walmsley@sifive.com>
Cc: Palmer Dabbelt <palmer@dabbelt.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Vasily Gorbik <gor@linux.ibm.com>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
Cc: Rich Felker <dalias@libc.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: x86@kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-ia64@vger.kernel.org
Cc: linux-mips@vger.kernel.org
Cc: linux-parisc@vger.kernel.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-riscv@lists.infradead.org
Cc: linux-s390@vger.kernel.org
Cc: linux-sh@vger.kernel.org
Cc: sparclinux@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: linux-arch@vger.kernel.org
Cc: linux-kernel@vger.kernel.org

Anshuman Khandual (3):
  arm64/mm: Drop __HAVE_ARCH_HUGE_PTEP_GET
  mm/hugetlb: Introduce HAVE_ARCH_IS_HUGEPAGE_ONLY_RANGE
  mm/hugetlb: Introduce HAVE_ARCH_CLEAR_HUGEPAGE_FLAGS

 arch/arm/include/asm/hugetlb.h     |  7 +------
 arch/arm64/include/asm/hugetlb.h   | 13 +------------
 arch/ia64/include/asm/hugetlb.h    |  5 +----
 arch/mips/include/asm/hugetlb.h    | 11 -----------
 arch/parisc/include/asm/hugetlb.h  | 10 ----------
 arch/powerpc/include/asm/hugetlb.h |  5 +----
 arch/riscv/include/asm/hugetlb.h   | 10 ----------
 arch/s390/include/asm/hugetlb.h    |  8 +-------
 arch/sh/include/asm/hugetlb.h      |  7 +------
 arch/sparc/include/asm/hugetlb.h   | 10 ----------
 arch/x86/include/asm/hugetlb.h     | 10 ----------
 include/linux/hugetlb.h            | 12 ++++++++++++
 12 files changed, 18 insertions(+), 90 deletions(-)

-- 
2.20.1
