From: Russell King <rmk+kernel@arm.linux.org.uk>
Date: Thu, 28 Apr 2016 09:27:59 +0000
Subject: [PATCH 03/12] ARM: kexec: remove 512MB restriction on kexec crashdump
Message-Id: <E1aviEp-0000ir-7s@rmk-PC.arm.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160428092644.GX19428@n2100.arm.linux.org.uk>
In-Reply-To: <20160428092644.GX19428@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org
Cc: devicetree@vger.kernel.org, Eric Biederman <ebiederm@xmission.com>, Fenghua Yu <fenghua.yu@intel.com>, Haren Myneni <hbabu@us.ibm.com>, Ian Campbell <ijc+devicetree@hellion.org.uk>, Jonathan Corbet <corbet@lwn.net>, kexec@lists.infradead.org, Kumar Gala <galak@codeaurora.org>, linux-doc@vger.kernel.org, linux-ia64@vger.kernel.org, Mark Rutland <mark.rutland@arm.com>, Pawel Moll <pawel.moll@arm.com>, Rob Herring <robh+dt@kernel.org>, Santosh Shilimkar <ssantosh@kernel.org>, Tony Luck <tony.luck@intel.com>, Vivek Goyal <vgoyal@redhat.com>

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 arch/arm/kernel/setup.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/arch/arm/kernel/setup.c b/arch/arm/kernel/setup.c
index 77b54c461c52..d9317eec1eba 100644
--- a/arch/arm/kernel/setup.c
+++ b/arch/arm/kernel/setup.c
@@ -943,7 +943,6 @@ late_initcall(init_machine_late);
  * zImage relocating below the reserved region.
  */
 #define CRASH_ALIGN	(128 << 20)
-#define CRASH_ADDR_MAX	(PHYS_OFFSET + (512 << 20))
 
 static inline unsigned long long get_total_mem(void)
 {
@@ -973,9 +972,7 @@ static void __init reserve_crashkernel(void)
 		return;
 
 	if (crash_base <= 0) {
-		unsigned long long crash_max = CRASH_ADDR_MAX;
-		if (crash_max > (u32)~0)
-			crash_max = (u32)~0;
+		unsigned long long crash_max = idmap_to_phys((u32)~0);
 		crash_base = memblock_find_in_range(CRASH_ALIGN, crash_max,
 						    crash_size, CRASH_ALIGN);
 		if (!crash_base) {
-- 
2.1.0

