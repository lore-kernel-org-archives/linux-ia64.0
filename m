From: Masahiro Yamada <yamada.masahiro@socionext.com>
Date: Fri, 27 Mar 2015 11:43:34 +0000
Subject: [PATCH 0/4] kbuild: refactor Makefile inclusion
Message-Id: <1427456618-23830-1-git-send-email-yamada.masahiro@socionext.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kbuild@vger.kernel.org
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>, linux-mips@linux-mips.org, Tony Luck <tony.luck@intel.com>, x86@kernel.org, linux-ia64@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, Jeff Dike <jdike@addtoit.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Russell King <linux@arm.linux.org.uk>, Richard Weinberger <richard@nod.at>, Michal Marek <mmarek@suse.cz>, user-mode-linux-user@lists.sourceforge.net, Ingo Molnar <mingo@redhat.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, linux-arm-kernel@lists.infradead.org

Masahiro Yamada (4):
  kbuild: use relative path to include Makefile
  kbuild: use relative path more to include Makefile
  kbuild: include $(src)/Makefile rather than $(obj)/Makefile
  kbuild: ia64: use $(src)/Makefile.gate rather than particular path

 Makefile                  | 22 ++++++++++------------
 arch/arm/boot/Makefile    |  2 +-
 arch/ia64/kernel/Makefile |  2 +-
 arch/mips/Makefile        |  2 +-
 arch/um/Makefile          |  6 +++---
 arch/x86/Makefile         |  2 +-
 arch/x86/Makefile.um      |  2 +-
 scripts/Makefile.dtbinst  |  2 +-
 scripts/Makefile.fwinst   |  2 +-
 9 files changed, 20 insertions(+), 22 deletions(-)

-- 
1.9.1

