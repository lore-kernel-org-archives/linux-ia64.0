From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Fri, 22 Jul 2016 21:24:42 +0000
Subject: [RFC v3 08/13] firmware/Makefile: force recompilation if makefile changes
Message-Id: <1469222687-1600-9-git-send-email-mcgrof@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1469222687-1600-1-git-send-email-mcgrof@kernel.org>
In-Reply-To: <1469222687-1600-1-git-send-email-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, linux@arm.linux.org.uk, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com
Cc: gnomes@lxorguk.ukuu.org.uk, linux-ia64@vger.kernel.org, jkosina@suse.cz, benh@kernel.crashing.org, ming.lei@canonical.com, linux@rasmusvillemoes.dk, platform-driver-x86@vger.kernel.org, paul.gortmaker@windriver.com, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, xen-devel@lists.xensource.com, linux-sh@vger.kernel.org, x86@kernel.org, fontana@sharpeleven.org, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, dvhart@infradead.org, dwmw2@infradead.org, pali.rohar@gmail.com, keescook@chromium.org, arnd@arndb.de, will.deacon@arm.com, rusty@rustcorp.com.au, rostedt@goodmis.org, christopher.denicolo@suse.com, ak@linux.intel.com, ciaran.farrell@suse.com, jpoimboe@redhat.com, andriy.shevchenko@linux.intel.com, mcb30@ipxe.org, linux-kbuild@vger.kernel.org, alan@linux.intel.com, jgross@suse.com, pebolle@tiscali.nl, tony.luck@intel.com, ananth@in.ibm.com, gregk

If you modify the target asm we currently do not force the
recompilation of the firmware files. The target asm is in
the firmware/Makefile, peg this file as a dependency to
require re-compilation of firmware targets when the asm
changes.

v3: introduced in this series

Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>
---
 firmware/Makefile | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/firmware/Makefile b/firmware/Makefile
index e297e1b52636..fa3e81c2a97b 100644
--- a/firmware/Makefile
+++ b/firmware/Makefile
@@ -176,7 +176,8 @@ quiet_cmd_fwbin = MK_FW   $@
 wordsize_deps := $(wildcard include/config/64bit.h include/config/32bit.h \
 		include/config/ppc32.h include/config/ppc64.h \
 		include/config/superh32.h include/config/superh64.h \
-		include/config/x86_32.h include/config/x86_64.h)
+		include/config/x86_32.h include/config/x86_64.h \
+		firmware/Makefile)
 
 $(patsubst %,$(obj)/%.gen.S, $(fw-shipped-y)): %: $(wordsize_deps)
 	$(call cmd,fwbin,$(patsubst %.gen.S,%,$@))
-- 
2.8.4

