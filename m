From: Russell King <rmk+kernel@arm.linux.org.uk>
Date: Thu, 28 Apr 2016 09:27:48 +0000
Subject: [PATCH 01/12] ARM: kexec: fix crashkernel= handling
Message-Id: <E1aviEe-0000if-VZ@rmk-PC.arm.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160428092644.GX19428@n2100.arm.linux.org.uk>
In-Reply-To: <20160428092644.GX19428@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org
Cc: devicetree@vger.kernel.org, Eric Biederman <ebiederm@xmission.com>, Fenghua Yu <fenghua.yu@intel.com>, Haren Myneni <hbabu@us.ibm.com>, Ian Campbell <ijc+devicetree@hellion.org.uk>, Jonathan Corbet <corbet@lwn.net>, kexec@lists.infradead.org, Kumar Gala <galak@codeaurora.org>, linux-doc@vger.kernel.org, linux-ia64@vger.kernel.org, Mark Rutland <mark.rutland@arm.com>, Pawel Moll <pawel.moll@arm.com>, Rob Herring <robh+dt@kernel.org>, Santosh Shilimkar <ssantosh@kernel.org>, Tony Luck <tony.luck@intel.com>, Vivek Goyal <vgoyal@redhat.com>

When the kernel crashkernel parameter is specified with just a size, we
are supposed to allocate a region from RAM to store the crashkernel.
However, ARM merely reserves physical address zero with no checking that
there is even RAM there.

Fix this by lifting similar code from x86, importing it to ARM with the
ARM specific parameters added.  In the absence of any platform specific
information, we allocate the crashkernel region from the first 512MB of
physical memory.

Update the kdump documentation to reflect this change.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 Documentation/kdump/kdump.txt | 13 +++----------
 arch/arm/kernel/setup.c       | 29 +++++++++++++++++++++++++++++
 2 files changed, 32 insertions(+), 10 deletions(-)

diff --git a/Documentation/kdump/kdump.txt b/Documentation/kdump/kdump.txt
index bc4bd5a44b88..88ff63d5fde3 100644
--- a/Documentation/kdump/kdump.txt
+++ b/Documentation/kdump/kdump.txt
@@ -263,12 +263,6 @@ been removed from the machine.
     crashkernel=<range1>:<size1>[,<range2>:<size2>,...][@offset]
     range=start-[end]
 
-Please note, on arm, the offset is required.
-    crashkernel=<range1>:<size1>[,<range2>:<size2>,...]@offset
-    range=start-[end]
-
-    'start' is inclusive and 'end' is exclusive.
-
 For example:
 
     crashkernelQ2M-2G:64M,2G-:128M
@@ -307,10 +301,9 @@ Boot into System Kernel
    on the memory consumption of the kdump system. In general this is not
    dependent on the memory size of the production system.
 
-   On arm, use "crashkernel=Y@X". Note that the start address of the kernel
-   will be aligned to 128MiB (0x08000000), so if the start address is not then
-   any space below the alignment point may be overwritten by the dump-capture kernel,
-   which means it is possible that the vmcore is not that precise as expected.
+   On arm, the use of "crashkernel=Y@X" is no longer necessary; the
+   kernel will automatically locate the crash kernel image within the
+   first 512MB of RAM if X is not given.
 
 
 Load the Dump-capture Kernel
diff --git a/arch/arm/kernel/setup.c b/arch/arm/kernel/setup.c
index 139791ed473d..77b54c461c52 100644
--- a/arch/arm/kernel/setup.c
+++ b/arch/arm/kernel/setup.c
@@ -938,6 +938,13 @@ static int __init init_machine_late(void)
 late_initcall(init_machine_late);
 
 #ifdef CONFIG_KEXEC
+/*
+ * The crash region must be aligned to 128MB to avoid
+ * zImage relocating below the reserved region.
+ */
+#define CRASH_ALIGN	(128 << 20)
+#define CRASH_ADDR_MAX	(PHYS_OFFSET + (512 << 20))
+
 static inline unsigned long long get_total_mem(void)
 {
 	unsigned long total;
@@ -965,6 +972,28 @@ static void __init reserve_crashkernel(void)
 	if (ret)
 		return;
 
+	if (crash_base <= 0) {
+		unsigned long long crash_max = CRASH_ADDR_MAX;
+		if (crash_max > (u32)~0)
+			crash_max = (u32)~0;
+		crash_base = memblock_find_in_range(CRASH_ALIGN, crash_max,
+						    crash_size, CRASH_ALIGN);
+		if (!crash_base) {
+			pr_err("crashkernel reservation failed - No suitable area found.\n");
+			return;
+		}
+	} else {
+		unsigned long long start;
+
+		start = memblock_find_in_range(crash_base,
+					       crash_base + crash_size,
+					       crash_size, SECTION_SIZE);
+		if (start != crash_base) {
+			pr_err("crashkernel reservation failed - memory is in use.\n");
+			return;
+		}
+	}
+
 	ret = memblock_reserve(crash_base, crash_size);
 	if (ret < 0) {
 		pr_warn("crashkernel reservation failed - memory is in use (0x%lx)\n",
-- 
2.1.0

