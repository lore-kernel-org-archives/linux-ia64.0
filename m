From: mcgrof@kernel.org
Date: Fri, 19 Aug 2016 21:32:58 +0000
Subject: [PATCH v4 09/16] firmware/Makefile: force recompilation if makefile changes
Message-Id: <1471642385-5629-10-git-send-email-mcgrof@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471642385-5629-1-git-send-email-mcgrof@kernel.org>
In-Reply-To: <1471642385-5629-1-git-send-email-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, bp@alien8.de, linux@arm.linux.org.uk, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com
Cc: gnomes@lxorguk.ukuu.org.uk, linux-ia64@vger.kernel.org, jkosina@suse.cz, benh@kernel.crashing.org, ming.lei@canonical.com, linux@rasmusvillemoes.dk, platform-driver-x86@vger.kernel.org, James.Bottomley@HansenPartnership.com, paul.gortmaker@windriver.com, paulus@samba.org, sparclinux@vger.kernel.org, mchehab@osg.samsung.com, linux-arch@vger.kernel.org, markus.heiser@darmarit.de, xen-devel@lists.xensource.com, msalter@redhat.com, linux-sh@vger.kernel.org, mpe@ellerman.id.au, x86@kernel.org, fontana@sharpeleven.org, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, dvhart@infradead.org, dwmw2@infradead.org, linux-xtensa@linux-xtensa.org, pali.rohar@gmail.com, keescook@chromium.org, arnd@arndb.de, jani.nikula@intel.com, will.deacon@arm.com, rusty@rustcorp.com.au, rostedt@goodmis.org, acme@redhat.com, ak@linux.intel.com, andriy.shevchenko@linux.intel.com, mcb30@ip

From: "Luis R. Rodriguez" <mcgrof@kernel.org>

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
2.9.2

