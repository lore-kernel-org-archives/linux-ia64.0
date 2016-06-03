From: Russell King <rmk+kernel@armlinux.org.uk>
Date: Fri, 03 Jun 2016 08:50:43 +0000
Subject: [PATCH 7/8] ARM: keystone: dts: add psci command definition
Message-Id: <E1b8koV-0004Hf-2j@rmk-PC.armlinux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kexec@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, Rob Herring <robh+dt@kernel.org>, Pawel Moll <pawel.moll@arm.com>, Mark Rutland <mark.rutland@arm.com>, Ian Campbell <ijc+devicetree@hellion.org.uk>, Kumar Gala <galak@codeaurora.org>, devicetree@vger.kernel.org

From: Vitaly Andrianov <vitalya@ti.com>

This commit adds definition for cpu_on, cpu_off and cpu_suspend commands.
These definitions must match the corresponding PSCI definitions in
boot monitor.

Having those command and corresponding PSCI support in boot monitor allows
run time CPU hot plugin.

Signed-off-by: Keerthy <j-keerthy@ti.com>
Signed-off-by: Vitaly Andrianov <vitalya@ti.com>
Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 arch/arm/boot/dts/keystone.dtsi | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/arch/arm/boot/dts/keystone.dtsi b/arch/arm/boot/dts/keystone.dtsi
index 3f272826f537..007648971744 100644
--- a/arch/arm/boot/dts/keystone.dtsi
+++ b/arch/arm/boot/dts/keystone.dtsi
@@ -59,6 +59,14 @@
 			     <GIC_SPI 23 IRQ_TYPE_EDGE_RISING>;
 	};
 
+	psci {
+		compatible	= "arm,psci";
+		method		= "smc";
+		cpu_suspend	= <0x84000001>;
+		cpu_off		= <0x84000002>;
+		cpu_on		= <0x84000003>;
+	};
+
 	soc {
 		#address-cells = <1>;
 		#size-cells = <1>;
-- 
2.1.0

