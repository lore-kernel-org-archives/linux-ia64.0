From: akpm@linux-foundation.org
Date: Tue, 02 Feb 2010 22:42:01 +0000
Subject: [patch 1/1] arch/ia64/uv/kernel/setup.c: wrong attribute of HUB chip written in uv_setup()
Message-Id: <201002022242.o12Mg2Me019074@imap1.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Roel Kluin <roel.kluin@gmail.com>

n_val should be assigned to n_val attribute of HUB chip.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/ia64/uv/kernel/setup.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN arch/ia64/uv/kernel/setup.c~ia64-wrong-attribute-of-hub-chip-written-in-uv_setup arch/ia64/uv/kernel/setup.c
--- a/arch/ia64/uv/kernel/setup.c~ia64-wrong-attribute-of-hub-chip-written-in-uv_setup
+++ a/arch/ia64/uv/kernel/setup.c
@@ -104,7 +104,7 @@ void __init uv_setup(char **cmdline_p)
 		uv_cpu_hub_info(cpu)->lowmem_remap_top  			lowmem_redir_base + lowmem_redir_size;
 		uv_cpu_hub_info(cpu)->m_val = m_val;
-		uv_cpu_hub_info(cpu)->n_val = m_val;
+		uv_cpu_hub_info(cpu)->n_val = n_val;
 		uv_cpu_hub_info(cpu)->pnode_mask = (1 << n_val) -1;
 		uv_cpu_hub_info(cpu)->gpa_mask = (1 << (m_val + n_val)) - 1;
 		uv_cpu_hub_info(cpu)->gnode_upper = gnode_upper;
_
