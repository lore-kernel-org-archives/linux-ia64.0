From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 22 Oct 2016 19:57:50 +0000
Subject: [PATCH 5/6] IA64-sn_hwperf: Use seq_puts() in sn_topology_show()
Message-Id: <f73f8630-9ac5-ddbf-7586-d56706526aed@users.sourceforge.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <8daf03e1-5f6d-fc3b-c2db-397e6d4a9a1c@users.sourceforge.net>
In-Reply-To: <8daf03e1-5f6d-fc3b-c2db-397e6d4a9a1c@users.sourceforge.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, Borislav Petkov <bp@suse.de>, Fenghua Yu <fenghua.yu@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hans-Christian Noren Egtvedt <egtvedt@samfundet.no>, Ingo Molnar <mingo@kernel.org>, =?UTF-8?B?SsO2cmcgUsO2ZGVs?= <jroedel@suse.de>, Krzysztof Kozlowski <krzk@kernel.org>, Robert Richter <rrichter@cavium.com>, Robin Murphy <robin.murphy@arm.com>, Tony Luck <tony.luck@intel.com>, Toshi Kani <toshi.kani@hpe.com>, Vineet Gupta <vgupta@synopsys.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 22 Oct 2016 20:53:38 +0200

A string which did not contain a data format specification should be put
into a sequence. Thus use the corresponding function "seq_puts".

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 arch/ia64/sn/kernel/sn2/sn_hwperf.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/sn/kernel/sn2/sn_hwperf.c b/arch/ia64/sn/kernel/sn2/sn_hwperf.c
index b999257..435002a 100644
--- a/arch/ia64/sn/kernel/sn2/sn_hwperf.c
+++ b/arch/ia64/sn/kernel/sn2/sn_hwperf.c
@@ -400,9 +400,9 @@ static int sn_topology_show(struct seq_file *s, void *d)
 	int nasid_msb;
 
 	if (obj = objs) {
-		seq_printf(s, "# sn_topology version 2\n");
-		seq_printf(s, "# objtype ordinal location partition"
-			" [attribute value [, ...]]\n");
+		seq_puts(s,
+			 "# sn_topology version 2\n"
+			 "# objtype ordinal location partition [attribute value [, ...]]\n");
 
 		if (ia64_sn_get_sn_info(0,
 			&shubtype, &nasid_mask, &nasid_shift, &system_size,
-- 
2.10.1

