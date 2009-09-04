From: Amerigo Wang <amwang@redhat.com>
Date: Fri, 04 Sep 2009 10:09:36 +0000
Subject: [Patch 7/8] doc: update the kdump document
Message-Id: <20090904101203.5220.89839.sendpatchset@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090904101047.5220.20618.sendpatchset@localhost.localdomain>
In-Reply-To: <20090904101047.5220.20618.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Anton Vorontsov <avorontsov@ru.mvista.com>, tony.luck@intel.com, linux-ia64@vger.kernel.org, Neil Horman <nhorman@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>, Michael Ellerman <michael@ellerman.id.au>, "M. Mohan Kumar" <mohan@in.ibm.com>, akpm@linux-foundation.org, bernhard.walle@gmx.de, Fenghua Yu <fenghua.yu@intel.com>, kamezawa.hiroyu@jp.fujitsu.com, Amerigo Wang <amwang@redhat.com>


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
 
@@ -266,6 +275,26 @@ This would mean:
     2) if the RAM size is between 512M and 2G (exclusive), then reserve 64M
     3) if the RAM size is larger than 2G, then reserve 128M
 
+Or you can use:
+
+    crashkernel=auto
+
+if you have enough memory. The threshold is 4G on ia64 and x86, 2G on powerpc,
+below which this won't work.
+
+The automatically reserved memory size would be 128M on x86_32, 128M or 256M
+on ppc, 1/32 of your physical memory size on x86_64 and ppc64 (but it will not
+grow if you have more than 128G memory). IA64 has its own policy, shown below:
+
+	Memory size	Reserved memory
+	======	=======+	[4G, 12G)	256M
+	[12G, 128G)	512M
+	[128G, 256G)	768M
+	[256G, 378G)	1024M
+	[378G, 512G)	1536M
+	[512G, 768G)	2048M
+	[768G, )	3072M
 
 
 Boot into System Kernel
