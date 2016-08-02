From: Baole Ni <baolex.ni@intel.com>
Date: Tue, 02 Aug 2016 10:34:12 +0000
Subject: [PATCH 0012/1285] Replace numeric parameter like 0444 with macro
Message-Id: <20160802103412.14554-1-baolex.ni@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, fenghua.yu@intel.com, robert.jarzmik@free.fr, linux@armlinux.org.uk
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, chuansheng.liu@intel.com, baolex.ni@intel.com

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 arch/ia64/kernel/mca_drv.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/kernel/mca_drv.c b/arch/ia64/kernel/mca_drv.c
index 94f8bf7..3d04e56 100644
--- a/arch/ia64/kernel/mca_drv.c
+++ b/arch/ia64/kernel/mca_drv.c
@@ -788,7 +788,7 @@ void __exit mca_external_handler_exit(void)
 module_init(mca_external_handler_init);
 module_exit(mca_external_handler_exit);
 
-module_param(sal_rec_max, int, 0644);
+module_param(sal_rec_max, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(sal_rec_max, "Max size of SAL error record");
 
 MODULE_DESCRIPTION("ia64 platform dependent mca handler driver");
-- 
2.9.2

