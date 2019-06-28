From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Fri, 28 Jun 2019 04:56:41 +0000
Subject: [RFC 0/2] arm64: Enable vmemmap from device memory
Message-Id: <1561697083-7329-1-git-send-email-anshuman.khandual@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org
Cc: Anshuman Khandual <anshuman.khandual@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

This series enables vmemmap mapping allocation from device memory ranges on
arm64. Before that it enables vmemmap_populate_basepages() to accommodate
struct vmem_altmap based requests.

This series is based on linux next (next-20190613) along with v6 arm64
hot-remove series [1]. 

[1] https://lkml.org/lkml/2019/6/19/3

Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-ia64@vger.kernel.org
Cc: x86@kernel.org
Cc: linux-kernel@vger.kernel.org

Anshuman Khandual (2):
  mm/sparsemem: Add vmem_altmap support in vmemmap_populate_basepages()
  arm64/mm: Enable device memory allocation and free for vmemmap mapping

 arch/arm64/mm/mmu.c      | 57 +++++++++++++++++++++++++++++++-----------------
 arch/ia64/mm/discontig.c |  2 +-
 arch/x86/mm/init_64.c    |  4 ++--
 include/linux/mm.h       |  5 +++--
 mm/sparse-vmemmap.c      | 16 +++++++++-----
 5 files changed, 54 insertions(+), 30 deletions(-)

-- 
2.7.4
