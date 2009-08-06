From: Amerigo Wang <amwang@redhat.com>
Date: Thu, 06 Aug 2009 06:20:25 +0000
Subject: [Patch 7/7] doc: update the kdump document
Message-Id: <20090806062246.5578.33397.sendpatchset@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090806062125.5578.72123.sendpatchset@localhost.localdomain>
In-Reply-To: <20090806062125.5578.72123.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org, Neil Horman <nhorman@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andi Kleen <andi@firstfloor.org>, Amerigo Wang <amwang@redhat.com>, akpm@linux-foundation.org, Fenghua Yu <fenghua.yu@intel.com>, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>


Update the document for kdump.

Signed-off-by: WANG Cong <amwang@redhat.com>

---

Index: linux-2.6/Documentation/kdump/kdump.txt
=================================--- linux-2.6.orig/Documentation/kdump/kdump.txt
+++ linux-2.6/Documentation/kdump/kdump.txt
@@ -147,6 +147,15 @@ System kernel config options
    analysis tools require a vmlinux with debug symbols in order to read
    and analyze a dump file.
 
+4) Enable "automatically reserve memory for kexec kernel" in
+   "Processor type and features."
+
+   CONFIG_KEXEC_AUTO_RESERVE=y
+
+   This will let you to use "crashkernel=auto", instead of specifying
+   numbers for "crashkernel=". Note, you need to have enough memory.
+   The threshold and reserved memory size are arch-dependent.
+
 Dump-capture kernel config options (Arch Independent)
 -----------------------------------------------------
 
@@ -266,6 +275,13 @@ This would mean:
     2) if the RAM size is between 512M and 2G (exclusive), then reserve 64M
     3) if the RAM size is larger than 2G, then reserve 128M
 
+Or you can use:
+
+    crashkernel=auto
+
+if you have enough memory. The threshold is 4G, below which this won't work.
+Also the automatically reserved memory size would be 128M on x86, 256M on
+other platforms that have KEXEC.
 
 
 Boot into System Kernel
