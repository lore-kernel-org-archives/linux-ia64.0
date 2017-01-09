From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Mon, 09 Jan 2017 14:58:20 +0000
Subject: [PATCH v6 02/14] xtensa: skip adding literal when SORT() is used
Message-Id: <20170109145833.11502-3-mcgrof@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20161222023811.21246-1-mcgrof@kernel.org>
 <20170109145833.11502-1-mcgrof@kernel.org>
In-Reply-To: <20170109145833.11502-1-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hpa@zytor.com, acme@redhat.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, bp@alien8.de, npiggin@gmail.com, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, dalias@libc.org, linux@arm.linux.org.uk
Cc: gnomes@lxorguk.ukuu.org.uk, linux-ia64@vger.kernel.org, jkosina@suse.cz, benh@kernel.crashing.org, ming.lei@canonical.com, linux@rasmusvillemoes.dk, platform-driver-x86@vger.kernel.org, James.Bottomley@HansenPartnership.com, paul.gortmaker@windriver.com, paulus@samba.org, sparclinux@vger.kernel.org, wangnan0@huawei.com, mchehab@osg.samsung.com, linux-arch@vger.kernel.org, markus.heiser@darmarit.de, xen-devel@lists.xensource.com, msalter@redhat.com, linux-sh@vger.kernel.org, mpe@ellerman.id.au, joro@8bytes.org, x86@kernel.org, fontana@sharpeleven.org, dsahern@gmail.com, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, dvhart@infradead.org, dwmw2@infradead.org, linux@roeck-us.net, linux-xtensa@linux-xtensa.org, pali.rohar@gmail.com, keescook@chromium.org, arnd@arndb.de, jani.nikula@intel.com, will.deacon@arm.com, rusty@rustcorp.com.au, rostedt@goodmis.org

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

