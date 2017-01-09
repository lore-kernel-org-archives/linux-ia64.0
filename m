From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Mon, 09 Jan 2017 15:02:45 +0000
Subject: [PATCH v3 2/6] tools: add init.h for tools
Message-Id: <20170109150249.11667-3-mcgrof@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20161222023958.21306-1-mcgrof@kernel.org>
 <20170109150249.11667-1-mcgrof@kernel.org>
In-Reply-To: <20170109150249.11667-1-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hpa@zytor.com, acme@redhat.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, bp@alien8.de, npiggin@gmail.com, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, dalias@libc.org, linux@arm.linux.org.uk
Cc: x86@kernel.org, luto@amacapital.net, keescook@chromium.org, linux@roeck-us.net, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, pebolle@tiscali.nl, fontana@sharpeleven.org, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel.com, paul.gortmaker@windriver.com, xen-devel@lists.xensource.com, ak@linux.intel.com, pali.rohar@gmail.com, dvhart@infradead.org, platform-driver-x86@vger.kernel.org, mmarek@suse.com, linux@rasmusvillemoes.dk, jkosina@suse.cz, korea.drzix@gmail.com, linux-kbuild@vger.kernel

Start off with just __ref -- we enalbe you to override, if you do
that then you can define your own. The way you'd use this, if you
do override, is define your own __ref and then use include_next.

Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>
---
 tools/include/linux/init.h | 9 +++++++++
 1 file changed, 9 insertions(+)
 create mode 100644 tools/include/linux/init.h

diff --git a/tools/include/linux/init.h b/tools/include/linux/init.h
new file mode 100644
index 000000000000..6d970a360a05
--- /dev/null
+++ b/tools/include/linux/init.h
@@ -0,0 +1,9 @@
+#ifndef _TOOLS_LINUX_INIT_H
+#define _TOOLS_LINUX_INIT_H
+
+/* this means you can add your own to fit you own userspace needs */
+#ifndef __ref
+#define __ref
+#endif
+
+#endif /* _TOOLS_LINUX_INIT_H */
-- 
2.11.0

