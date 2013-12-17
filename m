From: Mark Salter <msalter@redhat.com>
Date: Tue, 17 Dec 2013 15:48:46 +0000
Subject: [PATCH v2 03/10] ia64: select ARCH_MIGHT_HAVE_PC_SERIO
Message-Id: <1387295333-24684-4-git-send-email-msalter@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1387295333-24684-1-git-send-email-msalter@redhat.com>
In-Reply-To: <1387295333-24684-1-git-send-email-msalter@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Mark Salter <msalter@redhat.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Architectures which might use an i8042 for serial IO to keyboard,
mouse, etc should select ARCH_MIGHT_HAVE_PC_SERIO.

Signed-off-by: Mark Salter <msalter@redhat.com>
CC: Tony Luck <tony.luck@intel.com>
CC: Fenghua Yu <fenghua.yu@intel.com>
CC: linux-ia64@vger.kernel.org
---
 arch/ia64/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 4e4119b..f7337aa 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -7,6 +7,7 @@ menu "Processor type and features"
 config IA64
 	bool
 	select ARCH_MIGHT_HAVE_PC_PARPORT
+	select ARCH_MIGHT_HAVE_PC_SERIO
 	select PCI if (!IA64_HP_SIM)
 	select ACPI if (!IA64_HP_SIM)
 	select PM if (!IA64_HP_SIM)
-- 
1.8.3.1

