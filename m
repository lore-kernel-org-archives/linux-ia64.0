From: Thierry Reding <thierry.reding@gmail.com>
Date: Mon, 28 Jul 2014 15:01:48 +0000
Subject: [PATCH 1/2] [IA64] Fix zeroing of PDAs
Message-Id: <1406559709-9401-1-git-send-email-thierry.reding@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

From: Thierry Reding <treding@nvidia.com>

The code uses a the following to zero out a PDA:

	memset(pda, 0, sizeof(pda));

But sizeof(pda) will return the size of a pointer rather than the size
of the structure pointed to. This triggers the following warning from
GCC:

	arch/ia64/sn/kernel/setup.c:582:23: warning: argument to 'sizeof' in 'memset' call is the same pointer type 'struct pda_s *' as the destination; expected 'struct pda_s' or an explicit length [-Wsizeof-pointer-memaccess]
	  memset(pda, 0, sizeof(pda));
	                       ^

Fix this by passing in the size of the structure using sizeof(*pda)
instead.

Signed-off-by: Thierry Reding <treding@nvidia.com>
---
 arch/ia64/sn/kernel/setup.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
index 53b01b8e2f19..36182c84363c 100644
--- a/arch/ia64/sn/kernel/setup.c
+++ b/arch/ia64/sn/kernel/setup.c
@@ -579,7 +579,7 @@ void sn_cpu_init(void)
 		       (sn_prom_type = 1) ? "real" : "fake");
 	}
 
-	memset(pda, 0, sizeof(pda));
+	memset(pda, 0, sizeof(*pda));
 	if (ia64_sn_get_sn_info(0, &sn_hub_info->shub2,
 				&sn_hub_info->nasid_bitmask,
 				&sn_hub_info->nasid_shift,
-- 
2.0.2

