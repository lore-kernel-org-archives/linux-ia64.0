From: mcgrof@kernel.org
Date: Fri, 19 Aug 2016 21:41:10 +0000
Subject: [PATCH v1 2/7] tools: add a basic tools printk.h
Message-Id: <1471642875-5957-3-git-send-email-mcgrof@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471642454-5679-1-git-send-email-mcgrof@kernel.org>
 <1471642875-5957-1-git-send-email-mcgrof@kernel.org>
In-Reply-To: <1471642875-5957-1-git-send-email-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: acme@redhat.com, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, bp@alien8.de, linux@arm.linux.org.uk, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com
Cc: x86@kernel.org, luto@amacapital.net, keescook@chromium.org, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, ananth@in.ibm.com, pebolle@tiscali.nl, fontana@sharpeleven.org, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel.com, paul.gortmaker@windriver.com, xen-devel@lists.xensource.com, ak@linux.intel.com, pali.rohar@gmail.com, dvhart@infradead.org, platform-driver-x86@vger.kernel.org, mmarek@suse.com, linux@rasmusvillemoes.dk, jkosina@suse.cz, korea.drzix@gmail.com, linux-kbuild@vger.kernel.org, ton

From: "Luis R. Rodriguez" <mcgrof@kernel.org>

This will be used later by the userspace linker-tables sandbox.
Since upstream kernel.h includes printk.h mimic this so we can
match and replicate C code as-is on userspace sandbox tools.

Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>
---
 tools/include/linux/kernel.h |  1 +
 tools/include/linux/printk.h | 14 ++++++++++++++
 2 files changed, 15 insertions(+)
 create mode 100644 tools/include/linux/printk.h

diff --git a/tools/include/linux/kernel.h b/tools/include/linux/kernel.h
index 3d385a6d4fc1..afdf760bf35c 100644
--- a/tools/include/linux/kernel.h
+++ b/tools/include/linux/kernel.h
@@ -6,6 +6,7 @@
 #include <assert.h>
 
 #include <linux/bug.h>
+#include <linux/printk.h>
 
 #define DIV_ROUND_UP(n,d) (((n) + (d) - 1) / (d))
 
diff --git a/tools/include/linux/printk.h b/tools/include/linux/printk.h
new file mode 100644
index 000000000000..7e34e9c817e8
--- /dev/null
+++ b/tools/include/linux/printk.h
@@ -0,0 +1,14 @@
+#ifndef __TOOLS_KERNEL_PRINTK__
+#define __TOOLS_KERNEL_PRINTK__
+
+#include <stdio.h>
+
+#ifndef pr_fmt
+#define pr_fmt(fmt)	fmt
+#endif
+
+#define pr_info(fmt, ...)	printf(pr_fmt(fmt), ##__VA_ARGS__)
+#define pr_err(fmt, ...)	printf(pr_fmt(fmt), ##__VA_ARGS__)
+#define pr_debug(fmt, ...)	printf(pr_fmt(fmt), ##__VA_ARGS__)
+
+#endif /* __TOOLS_KERNEL_PRINTK__ */
-- 
2.9.2

