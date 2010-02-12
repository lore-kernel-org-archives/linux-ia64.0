From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 12 Feb 2010 17:12:51 +0000
Subject: [PATCH] preserve personality flag bits across exec
Message-Id: <89k83a$786sk6@azsmga001.ch.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In its <asm/elf.h> ia64 defines SET_PERSONALITY in a way that unconditionally
sets the personality of the current process to PER_LINUX, losing any flag bits
from the upper 3 bytes of current->personality.  This is wrong. Those bits are
intended to be inherited across exec (other code takes care of ensuring that
security sensitive bits like ADDR_NO_RANDOMIZE are not passed to unsuspecting
setuid/setgid applications).
Date: Fri, 12 Feb 2010 09:12:50 -0800
Message-Id: <4b758c12105653e560@agluck-desktop.sc.intel.com>

Signed-off-by: Tony Luck <tony.luck@intel.com>

---

Technically elf32_set_personality() should have this same fix applied,
but the whole of arch/ia64/ia32/ is going to be deleted in the next
merge window, so there seems little point.

diff --git a/arch/ia64/include/asm/elf.h b/arch/ia64/include/asm/elf.h
index e14108b..4c41656 100644
--- a/arch/ia64/include/asm/elf.h
+++ b/arch/ia64/include/asm/elf.h
@@ -201,7 +201,9 @@ extern void ia64_elf_core_copy_regs (struct pt_regs *src, elf_gregset_t dst);
    relevant until we have real hardware to play with... */
 #define ELF_PLATFORM	NULL
 
-#define SET_PERSONALITY(ex)	set_personality(PER_LINUX)
+#define SET_PERSONALITY(ex)	\
+	set_personality((current->personality & ~PER_MASK) | PER_LINUX)
+
 #define elf_read_implies_exec(ex, executable_stack)					\
 	((executable_stack!=EXSTACK_DISABLE_X) && ((ex).e_flags & EF_IA_64_LINUX_EXECUTABLE_STACK) != 0)
 
