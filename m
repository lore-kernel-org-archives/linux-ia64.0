From: Zi Yan <zi.yan@sent.com>
Date: Thu, 06 May 2021 15:26:22 +0000
Subject: [RFC PATCH 6/7] arch: x86: no MAX_ORDER exceeds SECTION_SIZE check for 32bit vdso.
Message-Id: <20210506152623.178731-7-zi.yan@sent.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210506152623.178731-1-zi.yan@sent.com>
In-Reply-To: <20210506152623.178731-1-zi.yan@sent.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>, Oscar Salvador <osalvador@suse.de>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org, Andy Lutomirski <luto@kernel.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@kernel.org>, Anshuman Khandual <anshuman.khandual@arm.com>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, Wei Yang <richard.weiyang@linux.alibaba.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, Zi Yan <ziy@nvidia.com>

From: Zi Yan <ziy@nvidia.com>

For x86_64, 32bit vdso is compiled for compatibility reason and 32bit
SECTION_SIZE_BITS value is used during compilation. It causes
compilation time error when MAX_ORDER is increased in the 64bit
environment even if it is OK for 64bit SECTION_SIZE_BITS. Remove the
check during 32bit vdso compilation. It will be checked when other
kernel components are compiled.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 arch/x86/entry/vdso/Makefile | 1 +
 include/linux/mmzone.h       | 2 ++
 2 files changed, 3 insertions(+)

diff --git a/arch/x86/entry/vdso/Makefile b/arch/x86/entry/vdso/Makefile
index 05c4abc2fdfd..cad339136ed1 100644
--- a/arch/x86/entry/vdso/Makefile
+++ b/arch/x86/entry/vdso/Makefile
@@ -156,6 +156,7 @@ KBUILD_CFLAGS_32 += -fno-stack-protector
 KBUILD_CFLAGS_32 += $(call cc-option, -foptimize-sibling-calls)
 KBUILD_CFLAGS_32 += -fno-omit-frame-pointer
 KBUILD_CFLAGS_32 += -DDISABLE_BRANCH_PROFILING
+KBUILD_CFLAGS_32 += -DNO_MAX_ORDER_CHECK
 
 ifdef CONFIG_RETPOLINE
 ifneq ($(RETPOLINE_VDSO_CFLAGS),)
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 965a0cd5eac1..fb5a0c2ab528 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1211,9 +1211,11 @@ static inline struct zoneref *first_zones_zonelist(struct zonelist *zonelist,
 #define SECTION_BLOCKFLAGS_BITS \
 	((1UL << (PFN_SECTION_SHIFT - pageblock_order)) * NR_PAGEBLOCK_BITS)
 
+#ifndef NO_MAX_ORDER_CHECK
 #if (MAX_ORDER - 1 + PAGE_SHIFT) > SECTION_SIZE_BITS
 #error Allocator MAX_ORDER exceeds SECTION_SIZE
 #endif
+#endif
 
 static inline unsigned long pfn_to_section_nr(unsigned long pfn)
 {
-- 
2.30.2
