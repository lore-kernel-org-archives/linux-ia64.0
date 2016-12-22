From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Thu, 22 Dec 2016 02:39:55 +0000
Subject: [PATCH v2 3/6] tools: add __used and enable to override
Message-Id: <20161222023958.21306-4-mcgrof@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471642875-5957-1-git-send-email-mcgrof@kernel.org>
 <20161222023958.21306-1-mcgrof@kernel.org>
In-Reply-To: <20161222023958.21306-1-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hpa@zytor.com, acme@redhat.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, bp@alien8.de, npiggin@gmail.com, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, dalias@libc.org, linux@arm.linux.org.uk
Cc: x86@kernel.org, luto@amacapital.net, keescook@chromium.org, linux@roeck-us.net, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, pebolle@tiscali.nl, fontana@sharpeleven.org, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel.com, paul.gortmaker@windriver.com, xen-devel@lists.xensource.com, ak@linux.intel.com, pali.rohar@gmail.com, dvhart@infradead.org, platform-driver-x86@vger.kernel.org, mmarek@suse.com, linux@rasmusvillemoes.dk, jkosina@suse.cz, korea.drzix@gmail.com, linux-kbuild@vger.kernel

This adds __used, to be used later in the userspace linker-tables
sandbox. If any userspace applicaiton wants to override they can
add their own definition and then use include_next.

This definition should probably suffice for most uses cases though.

Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>
---
 tools/include/linux/compiler.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/tools/include/linux/compiler.h b/tools/include/linux/compiler.h
index e33fc1df3935..556c991de212 100644
--- a/tools/include/linux/compiler.h
+++ b/tools/include/linux/compiler.h
@@ -5,6 +5,12 @@
 /* The "volatile" is due to gcc bugs */
 #define barrier() __asm__ __volatile__("": : :"memory")
 
+
+/* You can override as you see fit on your userspace tool */
+#ifndef __used
+#define __used          __attribute__((__used__))
+#endif
+
 #ifndef __always_inline
 # define __always_inline	inline __attribute__((always_inline))
 #endif
-- 
2.10.1

