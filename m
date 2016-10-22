From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 22 Oct 2016 19:54:19 +0000
Subject: [PATCH 2/6] IA64-sba_iommu: Combine four seq_printf() calls into two calls in ioc_show()
Message-Id: <1ee34747-6015-17d0-0ab7-817b3eec8f78@users.sourceforge.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <8daf03e1-5f6d-fc3b-c2db-397e6d4a9a1c@users.sourceforge.net>
In-Reply-To: <8daf03e1-5f6d-fc3b-c2db-397e6d4a9a1c@users.sourceforge.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, Borislav Petkov <bp@suse.de>, Fenghua Yu <fenghua.yu@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hans-Christian Noren Egtvedt <egtvedt@samfundet.no>, Ingo Molnar <mingo@kernel.org>, =?UTF-8?B?SsO2cmcgUsO2ZGVs?= <jroedel@suse.de>, Krzysztof Kozlowski <krzk@kernel.org>, Robert Richter <rrichter@cavium.com>, Robin Murphy <robin.murphy@arm.com>, Tony Luck <tony.luck@intel.com>, Toshi Kani <toshi.kani@hpe.com>, Vineet Gupta <vgupta@synopsys.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 22 Oct 2016 20:22:46 +0200

Some data were printed into a sequence by four separate function calls.
Print the same data by two function calls instead.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 arch/ia64/hp/common/sba_iommu.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
index 282f5c1..0688441 100644
--- a/arch/ia64/hp/common/sba_iommu.c
+++ b/arch/ia64/hp/common/sba_iommu.c
@@ -1906,14 +1906,20 @@ ioc_show(struct seq_file *s, void *v)
 	if (ioc->node != NUMA_NO_NODE)
 		seq_printf(s, "NUMA node       : %d\n", ioc->node);
 #endif
-	seq_printf(s, "IOVA size       : %ld MB\n", ((ioc->pdir_size >> 3) * iovp_size)/(1024*1024));
-	seq_printf(s, "IOVA page size  : %ld kb\n", iovp_size/1024);
+	seq_printf(s,
+		   "IOVA size       : %ld MB\n"
+		   "IOVA page size  : %ld kb\n",
+		   ((ioc->pdir_size >> 3) * iovp_size) / (1024 * 1024)),
+		   iovp_size / 1024);
 
 	for (i = 0; i < (ioc->res_size / sizeof(unsigned long)); ++i, ++res_ptr)
 		used += hweight64(*res_ptr);
 
-	seq_printf(s, "PDIR size       : %d entries\n", ioc->pdir_size >> 3);
-	seq_printf(s, "PDIR used       : %d entries\n", used);
+	seq_printf(s,
+		   "PDIR size       : %d entries\n"
+		   "PDIR used       : %d entries\n",
+		   ioc->pdir_size >> 3,
+		   used);
 
 #ifdef PDIR_SEARCH_TIMING
 	{
-- 
2.10.1

