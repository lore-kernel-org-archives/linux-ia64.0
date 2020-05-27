From: Krzysztof Kozlowski <krzk@kernel.org>
Date: Wed, 27 May 2020 18:51:37 +0000
Subject: [RESEND PATCH] ia64: configs: Remove useless UEVENT_HELPER_PATH
Message-Id: <20200527185137.13335-1-krzk@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Krzysztof Kozlowski <krzk@kernel.org>

Remove the CONFIG_UEVENT_HELPER_PATH because:
1. It is disabled since commit 1be01d4a5714 ("driver: base: Disable
   CONFIG_UEVENT_HELPER by default") as its dependency (UEVENT_HELPER) was
   made default to 'n',
2. It is not recommended (help message: "This should not be used today
   [...] creates a high system load") and was kept only for ancient
   userland,
3. Certain userland specifically requests it to be disabled (systemd
   README: "Legacy hotplug slows down the system and confuses udev").

Signed-off-by: Krzysztof Kozlowski <krzk@kernel.org>
Acked-by: Geert Uytterhoeven <geert+renesas@glider.be>
---
 arch/ia64/configs/generic_defconfig | 1 -
 1 file changed, 1 deletion(-)

diff --git a/arch/ia64/configs/generic_defconfig b/arch/ia64/configs/generic_defconfig
index cb267a07c57f..f1c5aad6725e 100644
--- a/arch/ia64/configs/generic_defconfig
+++ b/arch/ia64/configs/generic_defconfig
@@ -37,7 +37,6 @@ CONFIG_INET=y
 CONFIG_IP_MULTICAST=y
 CONFIG_SYN_COOKIES=y
 # CONFIG_IPV6 is not set
-CONFIG_UEVENT_HELPER_PATH="/sbin/hotplug"
 CONFIG_CONNECTOR=y
 # CONFIG_PNP_DEBUG_MESSAGES is not set
 CONFIG_BLK_DEV_LOOP=m
-- 
2.17.1
