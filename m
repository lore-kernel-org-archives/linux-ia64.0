From: akpm@linux-foundation.org
Date: Tue, 13 Nov 2007 08:48:14 +0000
Subject: [patch 1/1] ia64: increase .data.patch offset
Message-Id: <200711130855.lAD8tBWd002649@imap1.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>

I get this:

/opt/crosstool/gcc-3.4.5-glibc-2.3.6/ia64-unknown-linux-gnu/lib/gcc/ia64-unknown-linux-gnu/3.4.5/../../../../ia64-unknown-linux-gnu/bin/ld: section .data.patch [a000000000000500 -> a000000000000507] overlaps section .dynamic [a0000000000003c8 -> a000000000000507]

Cc: "Luck, Tony" <tony.luck@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/ia64/kernel/gate.lds.S |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN arch/ia64/kernel/gate.lds.S~ia64-increase-datapatch-offset arch/ia64/kernel/gate.lds.S
--- a/arch/ia64/kernel/gate.lds.S~ia64-increase-datapatch-offset
+++ a/arch/ia64/kernel/gate.lds.S
@@ -30,7 +30,7 @@ SECTIONS
 	 * the dynamic symbol table et al.  If this amount is insufficient,
 	 * ld -shared will barf.  Just increase it here.
 	 */
-	. = GATE_ADDR + 0x500;
+	. = GATE_ADDR + 0x600;
 
 	.data.patch		: {
 		__start_gate_mckinley_e9_patchlist = .;
_
