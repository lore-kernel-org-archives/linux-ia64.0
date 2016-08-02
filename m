From: Baole Ni <baolex.ni@intel.com>
Date: Tue, 02 Aug 2016 10:34:16 +0000
Subject: [PATCH 0013/1285] Replace numeric parameter like 0444 with macro
Message-Id: <20160802103416.14622-1-baolex.ni@intel.com>
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
 arch/ia64/sn/kernel/tiocx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/sn/kernel/tiocx.c b/arch/ia64/sn/kernel/tiocx.c
index e35f648..d4f99f9 100644
--- a/arch/ia64/sn/kernel/tiocx.c
+++ b/arch/ia64/sn/kernel/tiocx.c
@@ -484,7 +484,7 @@ static ssize_t store_cxdev_control(struct device *dev, struct device_attribute *
 	return count;
 }
 
-DEVICE_ATTR(cxdev_control, 0644, show_cxdev_control, store_cxdev_control);
+DEVICE_ATTR(cxdev_control, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH, show_cxdev_control, store_cxdev_control);
 
 static int __init tiocx_init(void)
 {
-- 
2.9.2

