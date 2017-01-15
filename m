From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Sun, 15 Jan 2017 21:10:45 +0000
Subject: [PATCH v7 02/14] xtensa: skip adding literal when SORT() is used
Message-Id: <20170115211057.17167-3-mcgrof@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170109145833.11502-1-mcgrof@kernel.org>
 <20170115211057.17167-1-mcgrof@kernel.org>
In-Reply-To: <20170115211057.17167-1-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: bp@alien8.de, bp@suse.de, hpa@zytor.com, acme@redhat.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, npiggin@gmail.com, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, dalias@libc.org, linux@arm.linux.org.uk
Cc: x86@kernel.org, luto@amacapital.net, keescook@chromium.org, linux@roeck-us.net, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, pebolle@tiscali.nl, fontana@sharpeleven.org, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel.com, paul.gortmaker@windriver.com, xen-devel@lists.xensource.com, ak@linux.intel.com, pali.rohar@gmail.com, dvhart@infradead.org, platform-driver-x86@vger.kernel.org, mmarek@suse.com, linux@rasmusvillemoes.dk, jkosina@suse.cz, korea.drzix@gmail.com, linux-kbuild@vger.kernel

When SORT(foo.*) is used the current sed replacements add
SORT(foo.literal foo.*), this breaks linking. Avoid adding
literals for SORT globs, if needed, these need to be added
manually.

Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>
---
 arch/xtensa/kernel/Makefile | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/xtensa/kernel/Makefile b/arch/xtensa/kernel/Makefile
index 264fb89c444e..ccedd016a8e0 100644
--- a/arch/xtensa/kernel/Makefile
+++ b/arch/xtensa/kernel/Makefile
@@ -30,10 +30,10 @@ AFLAGS_mxhead.o += -mtext-section-literals
 #
 # Replicate rules in scripts/Makefile.build
 
-sed-y = -e ':a; s/\*(\([^)]*\)\.text\.unlikely/*(\1.literal.unlikely .{text}.unlikely/; ta; ' \
-	-e ':b; s/\*(\([^)]*\)\.text\(\.[a-z]*\)/*(\1.{text}\2.literal .{text}\2/; tb; ' \
-	-e ':c; s/\*(\([^)]*\)\(\.[a-z]*it\|\.ref\)\.text/*(\1\2.literal \2.{text}/; tc; ' \
-	-e ':d; s/\*(\([^)]\+ \|\)\.text/*(\1.literal .{text}/; td; ' \
+sed-y = -e ':a; s/\*(\([^)SORT]*\)\.text\.unlikely/*(\1.literal.unlikely .{text}.unlikely/; ta; ' \
+	-e ':b; s/\*(\([^)SORT]*\)\.text\(\.[a-z]*\)/*(\1.{text}\2.literal .{text}\2/; tb; ' \
+	-e ':c; s/\*(\([^SORT)]*\)\(\.[a-z]*it\|\.ref\)\.text/*(\1\2.literal \2.{text}/; tc; ' \
+	-e ':d; s/\*(\([^SORT)]\+ \|\)\.text/*(\1.literal .{text}/; td; ' \
 	-e 's/\.{text}/.text/g'
 
 quiet_cmd__cpp_lds_S = LDS     $@
-- 
2.11.0

