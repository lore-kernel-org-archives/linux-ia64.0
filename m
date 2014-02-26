From: Josh Triplett <josh@joshtriplett.org>
Date: Wed, 26 Feb 2014 10:15:56 +0000
Subject: [PATCH] ia64: select CONFIG_TTY for use of tty_write_message in unaligned
Message-Id: <20140226101556.GA23751@thin>
List-Id: <linux-ia64.vger.kernel.org>
References: <530d8dd5.N73la/TcxHdsINPu%fengguang.wu@intel.com>
 <20140226070745.GA8078@thin>
In-Reply-To: <20140226070745.GA8078@thin>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kbuild test robot <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

arch/ia64/kernel/unaligned.c uses tty_write_message to print an
unaligned access exception to the TTY of the current user process.
Enable TTY to prevent a build error.

Signed-off-by: Josh Triplett <josh@joshtriplett.org>
---
Not tested, but this *should* fix the build error with CONFIG_TTY=n.

Minimal fix, on the basis that few people on ia64 will care deeply about
kernel size enough to turn off TTY.  Ideally, I'd instead suggest
dropping the tty_write_message entirely, and just leaving the printk.
Bonus: no need to sprintf first.

 arch/ia64/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 0c8e553..6b83c66 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -44,6 +44,7 @@ config IA64
 	select HAVE_MOD_ARCH_SPECIFIC
 	select MODULES_USE_ELF_RELA
 	select ARCH_USE_CMPXCHG_LOCKREF
+	select TTY
 	default y
 	help
 	  The Itanium Processor Family is Intel's 64-bit successor to
-- 
1.9.0

