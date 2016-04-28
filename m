From: Russell King <rmk+kernel@arm.linux.org.uk>
Date: Thu, 28 Apr 2016 09:28:19 +0000
Subject: [PATCH 07/12] ARM: keystone: dts: add psci command definition
Message-Id: <E1aviF9-0000jM-Qs@rmk-PC.arm.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160428092644.GX19428@n2100.arm.linux.org.uk>
In-Reply-To: <20160428092644.GX19428@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org
Cc: devicetree@vger.kernel.org, Eric Biederman <ebiederm@xmission.com>, Fenghua Yu <fenghua.yu@intel.com>, Haren Myneni <hbabu@us.ibm.com>, Ian Campbell <ijc+devicetree@hellion.org.uk>, Jonathan Corbet <corbet@lwn.net>, kexec@lists.infradead.org, Kumar Gala <galak@codeaurora.org>, linux-doc@vger.kernel.org, linux-ia64@vger.kernel.org, Mark Rutland <mark.rutland@arm.com>, Pawel Moll <pawel.moll@arm.com>, Rob Herring <robh+dt@kernel.org>, Santosh Shilimkar <ssantosh@kernel.org>, Tony Luck <tony.luck@intel.com>, Vivek Goyal <vgoyal@redhat.com>

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

This patch is already queued by Santosh, and only exists as part of this
series for completeness.

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

