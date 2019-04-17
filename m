From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 17 Apr 2019 20:51:49 +0000
Subject: [PATCH v3 2/3] asm-generic: generalize asm/sockios.h
Message-Id: <20190417205404.1877560-2-arnd@arndb.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190417205404.1877560-1-arnd@arndb.de>
In-Reply-To: <20190417205404.1877560-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Cc: y2038@lists.linaro.org, Willem de Bruijn <willemdebruijn.kernel@gmail.com>, Deepa Dinamani <deepa.kernel@gmail.com>, Arnd Bergmann <arnd@arndb.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-parisc@vger.kernel.org, sparclinux@vger.kernel.org

ia64, parisc and sparc just use a copy of the generic version
of asm/sockios.h, and x86 is a redirect to the same file, so we
can just let the header file be generated.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
v3: no changes since v1
---
 arch/ia64/include/uapi/asm/sockios.h   | 21 ---------------------
 arch/parisc/include/uapi/asm/sockios.h | 14 --------------
 arch/sparc/include/uapi/asm/sockios.h  | 15 ---------------
 arch/x86/include/uapi/asm/sockios.h    |  1 -
 4 files changed, 51 deletions(-)
 delete mode 100644 arch/ia64/include/uapi/asm/sockios.h
 delete mode 100644 arch/parisc/include/uapi/asm/sockios.h
 delete mode 100644 arch/sparc/include/uapi/asm/sockios.h
 delete mode 100644 arch/x86/include/uapi/asm/sockios.h

diff --git a/arch/ia64/include/uapi/asm/sockios.h b/arch/ia64/include/uapi/asm/sockios.h
deleted file mode 100644
index f27a12f95d20..000000000000
--- a/arch/ia64/include/uapi/asm/sockios.h
+++ /dev/null
@@ -1,21 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
-#ifndef _ASM_IA64_SOCKIOS_H
-#define _ASM_IA64_SOCKIOS_H
-
-/*
- * Socket-level I/O control calls.
- *
- * Based on <asm-i386/sockios.h>.
- *
- * Modified 1998, 1999
- *	David Mosberger-Tang <davidm@hpl.hp.com>, Hewlett-Packard Co
- */
-#define FIOSETOWN 	0x8901
-#define SIOCSPGRP	0x8902
-#define FIOGETOWN	0x8903
-#define SIOCGPGRP	0x8904
-#define SIOCATMARK	0x8905
-#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
-#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
-
-#endif /* _ASM_IA64_SOCKIOS_H */
diff --git a/arch/parisc/include/uapi/asm/sockios.h b/arch/parisc/include/uapi/asm/sockios.h
deleted file mode 100644
index 66a3ba64d53f..000000000000
--- a/arch/parisc/include/uapi/asm/sockios.h
+++ /dev/null
@@ -1,14 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
-#ifndef __ARCH_PARISC_SOCKIOS__
-#define __ARCH_PARISC_SOCKIOS__
-
-/* Socket-level I/O control calls. */
-#define FIOSETOWN 	0x8901
-#define SIOCSPGRP	0x8902
-#define FIOGETOWN	0x8903
-#define SIOCGPGRP	0x8904
-#define SIOCATMARK	0x8905
-#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
-#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
-
-#endif
diff --git a/arch/sparc/include/uapi/asm/sockios.h b/arch/sparc/include/uapi/asm/sockios.h
deleted file mode 100644
index 18a3ec14a847..000000000000
--- a/arch/sparc/include/uapi/asm/sockios.h
+++ /dev/null
@@ -1,15 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
-#ifndef _ASM_SPARC_SOCKIOS_H
-#define _ASM_SPARC_SOCKIOS_H
-
-/* Socket-level I/O control calls. */
-#define FIOSETOWN 	0x8901
-#define SIOCSPGRP	0x8902
-#define FIOGETOWN	0x8903
-#define SIOCGPGRP	0x8904
-#define SIOCATMARK	0x8905
-#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
-#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
-
-#endif /* !(_ASM_SPARC_SOCKIOS_H) */
-
diff --git a/arch/x86/include/uapi/asm/sockios.h b/arch/x86/include/uapi/asm/sockios.h
deleted file mode 100644
index def6d4746ee7..000000000000
--- a/arch/x86/include/uapi/asm/sockios.h
+++ /dev/null
@@ -1 +0,0 @@
-#include <asm-generic/sockios.h>
-- 
2.20.0
