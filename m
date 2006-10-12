From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 12 Oct 2006 21:00:33 +0000
Subject: Re: [PATCH] IA64 export symbols empty_zero_page, ia64_ssc
Message-Id: <20061012210033.GA9669@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2AA634B8@scsmsx411.amr.corp.intel.com> <20061012001139.1fea6ecf.akpm@osdl.org> <20061012175536.GA8497@intel.com> <20061012123714.85ab4ebb.akpm@osdl.org>
In-Reply-To: <20061012123714.85ab4ebb.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: Judith Lebzelter <judith@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

[IA64] Fix allmodconfig build

The HP_SIMSCSI driver can't be built as a module (unhealthy
dependencies on things that shouldn't really be exported).

AMD and nVidia IDE support doesn't sound too useful for ia64
either :-)

Signed-off-by: Tony Luck <tony.luck@intel.com>

---

With these two patches allmodconfig builds (but takes 11m24s, ouch!)

diff --git a/arch/ia64/hp/sim/Kconfig b/arch/ia64/hp/sim/Kconfig
index 18ccb12..f92306b 100644
--- a/arch/ia64/hp/sim/Kconfig
+++ b/arch/ia64/hp/sim/Kconfig
@@ -13,8 +13,8 @@ config HP_SIMSERIAL_CONSOLE
 	depends on HP_SIMSERIAL
 
 config HP_SIMSCSI
-	tristate "Simulated SCSI disk"
-	depends on SCSI
+	bool "Simulated SCSI disk"
+	depends on SCSI=y
 
 endmenu
 
diff --git a/drivers/ide/Kconfig b/drivers/ide/Kconfig
index 0c68d0f..12ab7c6 100644
--- a/drivers/ide/Kconfig
+++ b/drivers/ide/Kconfig
@@ -486,6 +486,7 @@ config WDC_ALI15X3
 
 config BLK_DEV_AMD74XX
 	tristate "AMD and nVidia IDE support"
+	depends on X86
 	help
 	  This driver adds explicit support for AMD-7xx and AMD-8111 chips
 	  and also for the nVidia nForce chip.  This allows the kernel to
