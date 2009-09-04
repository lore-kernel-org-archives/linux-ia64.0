From: Amerigo Wang <amwang@redhat.com>
Date: Fri, 04 Sep 2009 10:08:55 +0000
Subject: [Patch 3/8] ia64: add CONFIG_KEXEC_AUTO_RESERVE
Message-Id: <20090904101122.5220.45724.sendpatchset@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090904101047.5220.20618.sendpatchset@localhost.localdomain>
In-Reply-To: <20090904101047.5220.20618.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org, Neil Horman <nhorman@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>, Michael Ellerman <michael@ellerman.id.au>, Amerigo Wang <amwang@redhat.com>, "M. Mohan Kumar" <mohan@in.ibm.com>, akpm@linux-foundation.org, bernhard.walle@gmx.de, Fenghua Yu <fenghua.yu@intel.com>, kamezawa.hiroyu@jp.fujitsu.com, Anton Vorontsov <avorontsov@ru.mvista.com>


Introduce a new config option KEXEC_AUTO_RESERVE for ia64.

Signed-off-by: WANG Cong <amwang@redhat.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>

---

Index: linux-2.6/arch/ia64/Kconfig
=================================--- linux-2.6.orig/arch/ia64/Kconfig
+++ linux-2.6/arch/ia64/Kconfig
@@ -582,6 +582,20 @@ config KEXEC
 	  support.  As of this writing the exact hardware interface is
 	  strongly in flux, so no good recommendation can be made.
 
+config KEXEC_AUTO_RESERVE
+	bool "automatically reserve memory for kexec kernel"
+	depends on KEXEC
+	default y
+	---help---
+	  Automatically reserve memory for a kexec kernel, so that you don't
+	  need to specify numbers for the "crashkernel=X@Y" boot option,
+	  instead you can use "crashkernel=auto". To make this work, you need
+	  to have more than 4G memory.
+
+	  The reserved memory size is different depends on how much memory
+	  you actually have. Please check Documentation/kdump/kdump.txt.
+	  If you doubt, say N.
+
 config CRASH_DUMP
 	  bool "kernel crash dumps"
 	  depends on IA64_MCA_RECOVERY && !IA64_HP_SIM && (!SMP || HOTPLUG_CPU)
