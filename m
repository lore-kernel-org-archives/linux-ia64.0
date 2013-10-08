From: Mark Salter <msalter@redhat.com>
Date: Tue, 08 Oct 2013 05:10:20 +0000
Subject: [PATCH v2 04/14] ia64: select ARCH_MAY_HAVE_PC_PARPORT
Message-Id: <1381209030-351-5-git-send-email-msalter@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1381209030-351-1-git-send-email-msalter@redhat.com>
In-Reply-To: <1381209030-351-1-git-send-email-msalter@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Mark Salter <msalter@redhat.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Architectures which support CONFIG_PARPORT_PC should select
ARCH_MAY_HAVE_PC_PARPORT.

Signed-off-by: Mark Salter <msalter@redhat.com>
CC: Tony Luck <tony.luck@intel.com>
CC: Fenghua Yu <fenghua.yu@intel.com>
CC: linux-ia64@vger.kernel.org
---
 arch/ia64/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 7740ab1..f88117a 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -6,6 +6,7 @@ menu "Processor type and features"
 
 config IA64
 	bool
+	select ARCH_MAY_HAVE_PC_PARPORT
 	select PCI if (!IA64_HP_SIM)
 	select ACPI if (!IA64_HP_SIM)
 	select PM if (!IA64_HP_SIM)
-- 
1.8.3.1

