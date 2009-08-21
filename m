From: Amerigo Wang <amwang@redhat.com>
Date: Fri, 21 Aug 2009 06:54:34 +0000
Subject: [Patch 2/8] x86: add CONFIG_KEXEC_AUTO_RESERVE
Message-Id: <20090821065659.4855.46369.sendpatchset@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090821065637.4855.32234.sendpatchset@localhost.localdomain>
In-Reply-To: <20090821065637.4855.32234.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org, Neil Horman <nhorman@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, kamezawa.hiroyu@jp.fujitsu.com, Andi Kleen <andi@firstfloor.org>, Amerigo Wang <amwang@redhat.com>, akpm@linux-foundation.org, bernhard.walle@gmx.de, Fenghua Yu <fenghua.yu@intel.com>, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>


Introduce a new config option KEXEC_AUTO_RESERVE for x86.

Signed-off-by: WANG Cong <amwang@redhat.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>

---

Index: linux-2.6/arch/x86/Kconfig
=================================--- linux-2.6.orig/arch/x86/Kconfig
+++ linux-2.6/arch/x86/Kconfig
@@ -1482,6 +1482,19 @@ config KEXEC
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
+	  On x86_32, 128M is reserved, on x86_64 1/32 of your memory is
+	  reserved, but it will not exceed 1T/32.
+
 config CRASH_DUMP
 	bool "kernel crash dumps"
 	depends on X86_64 || (X86_32 && HIGHMEM)
