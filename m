From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Thu, 22 Dec 2016 02:39:56 +0000
Subject: [PATCH v2 4/6] tools: expand export.h with VMLINUX_SYMBOL()
Message-Id: <20161222023958.21306-5-mcgrof@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471642875-5957-1-git-send-email-mcgrof@kernel.org>
 <20161222023958.21306-1-mcgrof@kernel.org>
In-Reply-To: <20161222023958.21306-1-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hpa@zytor.com, acme@redhat.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, bp@alien8.de, npiggin@gmail.com, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, dalias@libc.org, linux@arm.linux.org.uk
Cc: x86@kernel.org, luto@amacapital.net, keescook@chromium.org, linux@roeck-us.net, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, pebolle@tiscali.nl, fontana@sharpeleven.org, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel.com, paul.gortmaker@windriver.com, xen-devel@lists.xensource.com, ak@linux.intel.com, pali.rohar@gmail.com, dvhart@infradead.org, platform-driver-x86@vger.kernel.org, mmarek@suse.com, linux@rasmusvillemoes.dk, jkosina@suse.cz, korea.drzix@gmail.com, linux-kbuild@vger.kernel

This will be used later by the linker-table userspace sandbox.

Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>
---
 tools/include/linux/export.h | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/tools/include/linux/export.h b/tools/include/linux/export.h
index d07e586b9ba0..cb7d6b490e08 100644
--- a/tools/include/linux/export.h
+++ b/tools/include/linux/export.h
@@ -1,6 +1,28 @@
 #ifndef _TOOLS_LINUX_EXPORT_H_
 #define _TOOLS_LINUX_EXPORT_H_
 
+/*
+ * Export symbols from the kernel to modules.  Forked from module.h
+ * to reduce the amount of pointless cruft we feed to gcc when only
+ * exporting a simple symbol or two.
+ *
+ * Try not to add #includes here.  It slows compilation and makes kernel
+ * hackers place grumpy comments in header files.
+ */
+
+/* Some toolchains use a `_' prefix for all user symbols. */
+#ifdef CONFIG_HAVE_UNDERSCORE_SYMBOL_PREFIX
+#define __VMLINUX_SYMBOL(x) _##x
+#define __VMLINUX_SYMBOL_STR(x) "_" #x
+#else
+#define __VMLINUX_SYMBOL(x) x
+#define __VMLINUX_SYMBOL_STR(x) #x
+#endif
+
+/* Indirect, so macros are expanded before pasting. */
+#define VMLINUX_SYMBOL(x) __VMLINUX_SYMBOL(x)
+#define VMLINUX_SYMBOL_STR(x) __VMLINUX_SYMBOL_STR(x)
+
 #define EXPORT_SYMBOL(sym)
 #define EXPORT_SYMBOL_GPL(sym)
 #define EXPORT_SYMBOL_GPL_FUTURE(sym)
-- 
2.10.1

