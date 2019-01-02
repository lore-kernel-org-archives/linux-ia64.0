From: Firoz Khan <firoz.khan@linaro.org>
Date: Wed, 02 Jan 2019 15:34:45 +0000
Subject: [PATCH 0/2] ia64: Unify the system call scripts
Message-Id: <1546442567-20637-1-git-send-email-firoz.khan@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Thomas Gleixner <tglx@linutronix.de>, Kate Stewart <kstewart@linuxfoundation.org>
Cc: y2038@lists.linaro.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, arnd@arndb.de, deepa.kernel@gmail.com, marcin.juszkiewicz@linaro.org, firoz.khan@linaro.org

System call table generation support is provided for
alpha, ia64, m68k, microblaze, mips, parisc, powerpc,
sh, sparc and xtensa architectures. The implementat-
ions are almost similar across all the above archte-
ctures. In order to reduce the source code across all
the above architectures, create common ".sh" files and
keep it in the common directory, script/. This will 
be a generic scripts which can use for all the above
architectures.

This patch depends on;
 https://lore.kernel.org/lkml/1546439331-18646-1-git-send-email-firoz.khan@linaro.org/

Firoz Khan (2):
  ia64: remove nargs from __SYSCALL
  ia64: generate uapi header and system call table files

 arch/ia64/kernel/entry.S                |  2 +-
 arch/ia64/kernel/syscalls/Makefile      | 11 ++++++++--
 arch/ia64/kernel/syscalls/syscallhdr.sh | 36 ---------------------------------
 arch/ia64/kernel/syscalls/syscalltbl.sh | 32 -----------------------------
 4 files changed, 10 insertions(+), 71 deletions(-)
 delete mode 100644 arch/ia64/kernel/syscalls/syscallhdr.sh
 delete mode 100644 arch/ia64/kernel/syscalls/syscalltbl.sh

-- 
1.9.1
