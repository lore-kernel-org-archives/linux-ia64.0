From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 27 Aug 2003 16:52:45 +0000
Subject: RE: kernel update (relative to 2.6.0-test4)
Message-Id: <marc-linux-ia64-106200380616033@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106192276030286@msgid-missing>
In-Reply-To: <marc-linux-ia64-106192276030286@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

CONFIG_PM is set without a menu entry to turn it on/off.

--- tiger-numa/arch/ia64/Kconfig	Tue Aug 26 13:29:52 2003
+++ linux-2.6.0-test4/arch/ia64/Kconfig	Wed Aug 27 09:41:49 2003
@@ -264,7 +264,7 @@
 	  unsure, answer Y.
 
 config PM
-	bool
+	bool "Power Management support"
 	depends on IA64_GENERIC || IA64_DIG || IA64_HP_ZX1
 	default y
 	---help---
