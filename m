From: Tim Abbott <tabbott@MIT.EDU>
Date: Fri, 01 May 2009 00:04:02 +0000
Subject: [PATCH 0/5] section name cleanup for ia64
Message-Id: <1241136247-10623-1-git-send-email-tabbott@mit.edu>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sam Ravnborg <sam@ravnborg.org>
Cc: Linux kernel mailing list <linux-kernel@vger.kernel.org>, Anders Kaseorg <andersk@MIT.EDU>, Waseem Daher <wdaher@MIT.EDU>, Denys Vlasenko <vda.linux@googlemail.com>, Jeff Arnold <jbarnold@MIT.EDU>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Tim Abbott <tabbott@MIT.EDU>

This patch series cleans up the section names on the ia64
architecture.  It requires the architecture-independent macro
definitions from this patch series:

<http://www.spinics.net/lists/mips/msg33499.html>

The long-term goal here is to add support for building the kernel with
-ffunction-sections -fdata-sections.  This requires renaming all the
magic section names in the kernel of the form .text.foo, .data.foo,
.bss.foo, and .rodata.foo to not have collisions with sections
generated for code like:

static int nosave = 0; /* -fdata-sections places in .data.nosave */
static void head(); /* -ffunction-sections places in .text.head */

Note that these patches have not been boot-tested (aside from testing
the analogous changes on x86), since I don't have access to the
appropriate hardware.

	-Tim Abbott

Tim Abbott (5):
  ia64: Use .ref.text, not .text.init for start_ap.
  ia64: use new macro for .data.cacheline_aligned section.
  ia64: use new macros for .data.init_task
  ia64: use new macro for .data.read_mostly section.
  ia64: convert to new generic read_mostly support.

 arch/ia64/Kconfig              |    3 +++
 arch/ia64/include/asm/cache.h  |    2 --
 arch/ia64/kernel/head.S        |    2 +-
 arch/ia64/kernel/init_task.c   |    2 +-
 arch/ia64/kernel/vmlinux.lds.S |   15 +++------------
 arch/ia64/xen/xensetup.S       |    3 ++-
 6 files changed, 10 insertions(+), 17 deletions(-)

