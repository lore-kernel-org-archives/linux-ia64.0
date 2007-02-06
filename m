From: akpm@linux-foundation.org
Date: Tue, 06 Feb 2007 00:19:59 +0000
Subject: [patch 01/13] IA64: alignment bug in ldscript
Message-Id: <200702060021.l160L2Gp004181@shell0.pdx.osdl.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Kirill Korotaev <dev@openvz.org>

Occasionally the FSYS_RETURN patch list can have an odd length, causing other
data structures to get out of alignment.  In OpenVZ it is odd and we get
misaligned kernel image, which does not boot.

Signed-off-by: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Signed-off-by: Kirill Korotaev <dev@openvz.org>
Cc: "Luck, Tony" <tony.luck@intel.com>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/ia64/kernel/vmlinux.lds.S |    1 +
 1 file changed, 1 insertion(+)

diff -puN arch/ia64/kernel/vmlinux.lds.S~ia64-alignment-bug-in-ldscript arch/ia64/kernel/vmlinux.lds.S
--- a/arch/ia64/kernel/vmlinux.lds.S~ia64-alignment-bug-in-ldscript
+++ a/arch/ia64/kernel/vmlinux.lds.S
@@ -157,6 +157,7 @@ SECTIONS
 	}
 #endif
 
+  . = ALIGN(8);
    __con_initcall_start = .;
   .con_initcall.init : AT(ADDR(.con_initcall.init) - LOAD_OFFSET)
 	{ *(.con_initcall.init) }
_
