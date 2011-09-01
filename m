From: Ben Hutchings <ben@decadent.org.uk>
Date: Thu, 01 Sep 2011 04:46:00 +0000
Subject: [PATCH] ia64, gpio: GENERIC_GPIO default must be n
Message-Id: <1314852360.3092.155.camel@deadeye>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Since GPIOLIB is optional on ia64, GENERIC_GPIO must not be selected by
default.  If GPIOLIB is enabled, it will select GENERIC_GPIO.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
Same problem as alpha, seen in this build log:
<https://buildd.debian.org/status/fetch.php?pkg=linux-2.6&arch=ia64&ver=3.1.0~rc4-1~experimental.1&stamp14841718>.

Ben.

 arch/ia64/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 3ff7785..27489b6 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -92,7 +92,7 @@ config HAVE_SETUP_PER_CPU_AREA
 	def_bool y
 
 config GENERIC_GPIO
-	def_bool y
+	bool
 
 config DMI
 	bool
-- 
1.7.5.4


