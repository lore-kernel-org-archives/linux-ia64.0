From: Hari Bathini <hbathini@linux.vnet.ibm.com>
Date: Thu, 10 Nov 2016 11:58:39 +0000
Subject: [PATCH 3/3] powerpc/fadump: update documentation about crashkernel parameter reuse
Message-Id: <147877907994.31483.13329389660354279539.stgit@hbathini.in.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <147877899077.31483.3740501843050856595.stgit@hbathini.in.ibm.com>
In-Reply-To: <147877899077.31483.3740501843050856595.stgit@hbathini.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: fenghua.yu@intel.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, dyoung@redhat.com, kexec@lists.infradead.org, Mahesh J Salgaonkar <mahesh@linux.vnet.ibm.com>, ebiederm@xmission.com, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org, vgoyal@redhat.com

As we are reusing crashkernel parameter instead of fadump_reserve_mem
parameter to specify the memory to reserve for fadump's crash kernel,
update the documentation accordingly.

Signed-off-by: Hari Bathini <hbathini@linux.vnet.ibm.com>
---
 Documentation/powerpc/firmware-assisted-dump.txt |   23 ++++++++++++++--------
 1 file changed, 15 insertions(+), 8 deletions(-)

diff --git a/Documentation/powerpc/firmware-assisted-dump.txt b/Documentation/powerpc/firmware-assisted-dump.txt
index 3007bc9..8394bc8 100644
--- a/Documentation/powerpc/firmware-assisted-dump.txt
+++ b/Documentation/powerpc/firmware-assisted-dump.txt
@@ -55,10 +55,14 @@ as follows:
          booted with restricted memory. By default, the boot memory
          size will be the larger of 5% of system RAM or 256MB.
          Alternatively, user can also specify boot memory size
-         through boot parameter 'fadump_reserve_mem=' which will
-         override the default calculated size. Use this option
-         if default boot memory size is not sufficient for second
-         kernel to boot successfully.
+         through boot parameter 'crashkernel=' which will override
+         the default calculated size. Use this option if default
+         boot memory size is not sufficient for second kernel to
+         boot successfully. For syntax of crashkernel= parameter,
+         refer to Documentation/kdump/kdump.txt. If any offset is
+         provided in crashkernel= parameter, it will be ignored
+         as fadump reserves memory at end of RAM for boot memory
+         dump preservation in case of a crash.
 
 -- After the low memory (boot memory) area has been saved, the
    firmware will reset PCI and other hardware state.  It will
@@ -158,13 +162,16 @@ How to enable firmware-assisted dump (fadump):
 
 1. Set config option CONFIG_FA_DUMP=y and build kernel.
 2. Boot into linux kernel with 'fadump=on' kernel cmdline option.
-3. Optionally, user can also set 'fadump_reserve_mem=' kernel cmdline
+3. Optionally, user can also set 'crashkernel=' kernel cmdline
    to specify size of the memory to reserve for boot memory dump
    preservation.
 
-NOTE: If firmware-assisted dump fails to reserve memory then it will
-   fallback to existing kdump mechanism if 'crashkernel=' option
-   is set at kernel cmdline.
+NOTE: 1. 'fadump_reserve_mem=' parameter has been deprecated. Instead
+         use 'crashkernel=' to specify size of the memory to reserve
+         for boot memory dump preservation.
+      2. If firmware-assisted dump fails to reserve memory then it
+         will fallback to existing kdump mechanism if 'crashkernel='
+         option is set at kernel cmdline.
 
 Sysfs/debugfs files:
 ------------

