From: Stephane Eranian <eranian@hpl.hp.com>
Date: Fri, 01 Dec 2006 16:30:35 +0000
Subject: [PATCH] fix uninitialized string in get_model_name()
Message-Id: <20061201163035.GE31914@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

If ia64_pal_get_brand_info() fails in get_model_name() we may be copying
an invalid string.

changelog:
	- initialize brand[] in get_model_name()

signed-off-by: stephane eranian <eranian@hpl.hp.com>

diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 2fd4b7d..cc82f6a 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -616,6 +616,8 @@ get_model_name(__u8 family, __u8 model)
 {
 	char brand[128];
 
+	memset(brand, 0, sizeof(brand));
+
 	if (ia64_pal_get_brand_info(brand)) {
 		if (family = 0x7)
 			memcpy(brand, "Merced", 7);
-- 

-Stephane
