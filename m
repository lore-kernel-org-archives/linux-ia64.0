From: Amerigo Wang <amwang@redhat.com>
Date: Wed, 12 Aug 2009 08:15:32 +0000
Subject: [Patch 2/8] x86: implement crashkernel=auto
Message-Id: <20090812081755.5757.32765.sendpatchset@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090812081731.5757.25254.sendpatchset@localhost.localdomain>
In-Reply-To: <20090812081731.5757.25254.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org, Neil Horman <nhorman@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andi Kleen <andi@firstfloor.org>, Amerigo Wang <amwang@redhat.com>, akpm@linux-foundation.org, bernhard.walle@gmx.de, Fenghua Yu <fenghua.yu@intel.com>, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>


Implement "crashkernel=auto" for x86 first, other arch will be added in the
following patches.

Signed-off-by: WANG Cong <amwang@redhat.com>

---

Index: linux-2.6/kernel/kexec.c
=================================--- linux-2.6.orig/kernel/kexec.c
+++ linux-2.6/kernel/kexec.c
@@ -37,6 +37,7 @@
 #include <asm/io.h>
 #include <asm/system.h>
 #include <asm/sections.h>
+#include <asm/setup.h>
 
 /* Per cpu memory for storing cpu states in case of system crash. */
 note_buf_t* crash_notes;
@@ -1297,6 +1298,39 @@ int __init parse_crashkernel(char 		 *cm
 
 	ck_cmdline += 12; /* strlen("crashkernel=") */
 
+#ifdef CONFIG_KEXEC_AUTO_RESERVE
+	if (strncmp(ck_cmdline, "auto", 4) = 0) {
+		unsigned long long size;
+		int len;
+		char tmp[32];
+
+		size = arch_default_crash_size(system_ram);
+		if (size != 0) {
+			*crash_size = size;
+			*crash_base = arch_default_crash_base();
+			len = scnprintf(tmp, sizeof(tmp), "%luM@%luM",
+					(unsigned long)(*crash_size)>>20,
+					(unsigned long)(*crash_base)>>20);
+			/* 'len' can't be <= 4. */
+			if (likely((len - 4 + strlen(cmdline))
+					< COMMAND_LINE_SIZE - 1)) {
+				memmove(ck_cmdline + len, ck_cmdline + 4,
+					strlen(cmdline) - (ck_cmdline + 4 - cmdline) + 1);
+				memcpy(ck_cmdline, tmp, len);
+			}
+			return 0;
+		} else {
+			/*
+			 * We can't reserve memory auotmatcally,
+			 * remove "crashkernel=auto" from cmdline.
+			 */
+			ck_cmdline += 4; /* strlen("auto") */
+			memmove(ck_cmdline - 16, ck_cmdline,
+				strlen(cmdline) - (ck_cmdline - cmdline) + 1);
+			return -ENOMEM;
+		}
+	}
+#endif
 	/*
 	 * if the commandline contains a ':', then that's the extended
 	 * syntax -- if not, it must be the classic syntax
Index: linux-2.6/arch/x86/include/asm/kexec.h
=================================--- linux-2.6.orig/arch/x86/include/asm/kexec.h
+++ linux-2.6/arch/x86/include/asm/kexec.h
@@ -23,6 +23,7 @@
 
 #include <asm/page.h>
 #include <asm/ptrace.h>
+#include <asm-generic/kexec.h>
 
 /*
  * KEXEC_SOURCE_MEMORY_LIMIT maximum page get_free_page can return.
Index: linux-2.6/include/asm-generic/kexec.h
=================================--- /dev/null
+++ linux-2.6/include/asm-generic/kexec.h
@@ -0,0 +1,42 @@
+#ifndef _ASM_GENERIC_KEXEC_H
+#define _ASM_GENERIC_KEXEC_H
+
+#ifdef CONFIG_KEXEC_AUTO_RESERVE
+
+#ifndef KEXEC_AUTO_RESERVED_SIZE
+#define KEXEC_AUTO_RESERVED_SIZE (1ULL<<27) /* 128M */
+#endif
+#ifndef KEXEC_AUTO_THRESHOLD
+#define KEXEC_AUTO_THRESHOLD (1ULL<<32) /* 4G */
+#endif
+
+#ifndef ARCH_HAS_DEFAULT_CRASH_SIZE
+static inline
+unsigned long long arch_default_crash_size(unsigned long long total_size)
+{
+	if (total_size < KEXEC_AUTO_THRESHOLD)
+		return 0;
+	else {
+#ifdef CONFIG_64BIT
+		if (total_size > 1ULL<<40) /* 1TB */
+			return KEXEC_AUTO_RESERVED_SIZE
+				* (1ULL<<40 / KEXEC_AUTO_THRESHOLD);
+		return 1ULL<<ilog2(roundup(total_size/32, 1ULL<<21));
+#else
+		return KEXEC_AUTO_RESERVED_SIZE;
+#endif
+	}
+}
+#endif
+#ifndef ARCH_HAS_DEFAULT_CRASH_BASE
+static inline
+unsigned long long arch_default_crash_base(void)
+{
+	/* 0 means find the base address automatically. */
+	return 0;
+}
+#endif
+
+#endif /* CONFIG_KEXEC_AUTO_RESERVE */
+
+#endif
