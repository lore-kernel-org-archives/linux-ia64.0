From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 04 Apr 2017 23:01:41 +0000
Subject: [PATCH] ia64: restore symbol versions for symbols defined in assembly
Message-Id: <1491346901-19592-1-git-send-email-tony.luck@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <58E3B0D5020000780014C9F4@prv-mh.provo.novell.com>
In-Reply-To: <58E3B0D5020000780014C9F4@prv-mh.provo.novell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Jan Beulich <JBeulich@suse.com>

The ia64 build generates many warnings like this:

   WARNING: EXPORT symbol "empty_zero_page" [vmlinux] version generation
   failed, symbol will not be versioned.

Besides adding the necessary header this also requires fiddling with
some explicit .S -> .o rules.

Cc: IA64-ML <linux-ia64@vger.kernel.org>
Signed-off-by: Jan Beulich <jbeulich@suse.com>
Signed-off-by: Tony Luck <tony.luck@intel.com>
---
 arch/ia64/include/asm/asm-prototypes.h | 29 +++++++++++++++++++++++++++++
 arch/ia64/lib/Makefile                 | 16 ++++++++--------
 2 files changed, 37 insertions(+), 8 deletions(-)
 create mode 100644 arch/ia64/include/asm/asm-prototypes.h

diff --git a/arch/ia64/include/asm/asm-prototypes.h b/arch/ia64/include/asm/asm-prototypes.h
new file mode 100644
index 000000000000..a2c139808cfe
--- /dev/null
+++ b/arch/ia64/include/asm/asm-prototypes.h
@@ -0,0 +1,29 @@
+#ifndef _ASM_IA64_ASM_PROTOTYPES_H
+#define _ASM_IA64_ASM_PROTOTYPES_H
+
+#include <asm/cacheflush.h>
+#include <asm/checksum.h>
+#include <asm/esi.h>
+#include <asm/ftrace.h>
+#include <asm/page.h>
+#include <asm/pal.h>
+#include <asm/string.h>
+#include <asm/uaccess.h>
+#include <asm/unwind.h>
+#include <asm/xor.h>
+
+extern const char ia64_ivt[];
+
+signed int __divsi3(signed int, unsigned int);
+signed int __modsi3(signed int, unsigned int);
+
+signed long long __divdi3(signed long long, unsigned long long);
+signed long long __moddi3(signed long long, unsigned long long);
+
+unsigned int __udivsi3(unsigned int, unsigned int);
+unsigned int __umodsi3(unsigned int, unsigned int);
+
+unsigned long long __udivdi3(unsigned long long, unsigned long long);
+unsigned long long __umoddi3(unsigned long long, unsigned long long);
+
+#endif /* _ASM_IA64_ASM_PROTOTYPES_H */
diff --git a/arch/ia64/lib/Makefile b/arch/ia64/lib/Makefile
index 1f3d3877618f..0a40b14407b1 100644
--- a/arch/ia64/lib/Makefile
+++ b/arch/ia64/lib/Makefile
@@ -24,25 +24,25 @@ AFLAGS___modsi3.o	=	     -DMODULO
 AFLAGS___umodsi3.o	= -DUNSIGNED -DMODULO
 
 $(obj)/__divdi3.o: $(src)/idiv64.S FORCE
-	$(call if_changed_dep,as_o_S)
+	$(call if_changed_rule,as_o_S)
 
 $(obj)/__udivdi3.o: $(src)/idiv64.S FORCE
-	$(call if_changed_dep,as_o_S)
+	$(call if_changed_rule,as_o_S)
 
 $(obj)/__moddi3.o: $(src)/idiv64.S FORCE
-	$(call if_changed_dep,as_o_S)
+	$(call if_changed_rule,as_o_S)
 
 $(obj)/__umoddi3.o: $(src)/idiv64.S FORCE
-	$(call if_changed_dep,as_o_S)
+	$(call if_changed_rule,as_o_S)
 
 $(obj)/__divsi3.o: $(src)/idiv32.S FORCE
-	$(call if_changed_dep,as_o_S)
+	$(call if_changed_rule,as_o_S)
 
 $(obj)/__udivsi3.o: $(src)/idiv32.S FORCE
-	$(call if_changed_dep,as_o_S)
+	$(call if_changed_rule,as_o_S)
 
 $(obj)/__modsi3.o: $(src)/idiv32.S FORCE
-	$(call if_changed_dep,as_o_S)
+	$(call if_changed_rule,as_o_S)
 
 $(obj)/__umodsi3.o: $(src)/idiv32.S FORCE
-	$(call if_changed_dep,as_o_S)
+	$(call if_changed_rule,as_o_S)
-- 
2.7.4

