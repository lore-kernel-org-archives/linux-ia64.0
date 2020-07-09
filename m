From: Jia He <justin.he@arm.com>
Date: Thu, 09 Jul 2020 02:06:24 +0000
Subject: [PATCH v3 1/6] mm/memory_hotplug: introduce default dummy memory_add_physaddr_to_nid()
Message-Id: <20200709020629.91671-2-justin.he@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200709020629.91671-1-justin.he@arm.com>
In-Reply-To: <20200709020629.91671-1-justin.he@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, David Hildenbrand <david@redhat.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Chuhong Yuan <hslester96@gmail.com>, Mike Rapoport <rppt@linux.ibm.com>, Masahiro Yamada <masahiroy@kernel.org>, Michal Hocko <mhocko@suse.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, linux-nvdimm@lists.01.org, linux-mm@kvack.org, Jonathan Cameron <Jonathan.Cameron@Huawei.com>, Kaly Xin <Kaly.Xin@arm.com>, Jia He <justin.he@arm.com>

This is to introduce a general dummy helper. memory_add_physaddr_to_nid()
is a fallback option to get the nid in case NUMA_NO_NID is detected.

After this patch, arm64/sh/s390 can simply use the general dummy version.
PowerPC/x86/ia64 will still use their specific version.

Signed-off-by: Jia He <justin.he@arm.com>
---
 mm/memory_hotplug.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index da374cd3d45b..b49ab743d914 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -350,6 +350,16 @@ int __ref __add_pages(int nid, unsigned long pfn, unsigned long nr_pages,
 	return err;
 }
 
+#ifdef CONFIG_NUMA
+int __weak memory_add_physaddr_to_nid(u64 start)
+{
+	pr_info_once("Unknown target node for memory at 0x%llx, assuming node 0\n",
+			start);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(memory_add_physaddr_to_nid);
+#endif
+
 /* find the smallest valid pfn in the range [start_pfn, end_pfn) */
 static unsigned long find_smallest_section_pfn(int nid, struct zone *zone,
 				     unsigned long start_pfn,
-- 
2.17.1
