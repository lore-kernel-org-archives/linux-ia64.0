From: Roel Kluin <roel.kluin@gmail.com>
Date: Thu, 14 Jan 2010 22:21:47 +0000
Subject: [PATCH] IA64: Wrong attribute of HUB chip written in uv_setup() ?
Message-Id: <4B4F98FB.4080709@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

n_val should be assigned to n_val attribute of HUB chip.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
Is this right? please review.

diff --git a/arch/ia64/uv/kernel/setup.c b/arch/ia64/uv/kernel/setup.c
index 7a5ae63..f149065 100644
--- a/arch/ia64/uv/kernel/setup.c
+++ b/arch/ia64/uv/kernel/setup.c
@@ -104,7 +104,7 @@ void __init uv_setup(char **cmdline_p)
 		uv_cpu_hub_info(cpu)->lowmem_remap_top  			lowmem_redir_base + lowmem_redir_size;
 		uv_cpu_hub_info(cpu)->m_val = m_val;
-		uv_cpu_hub_info(cpu)->n_val = m_val;
+		uv_cpu_hub_info(cpu)->n_val = n_val;
 		uv_cpu_hub_info(cpu)->pnode_mask = (1 << n_val) -1;
 		uv_cpu_hub_info(cpu)->gpa_mask = (1 << (m_val + n_val)) - 1;
 		uv_cpu_hub_info(cpu)->gnode_upper = gnode_upper;
