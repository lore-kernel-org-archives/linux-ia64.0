From: Valentin Schneider <valentin.schneider@arm.com>
Date: Fri, 08 Oct 2021 11:53:45 +0000
Subject: [PATCH 0/2] sched: cleanup CONFIG_SCHED_MC & friends
Message-Id: <20211008115347.425234-1-valentin.schneider@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org
Cc: Peter Zijlstra <peterz@infradead.org>, aubrey.li@linux.intel.com, song.bao.hua@hisilicon.com, tim.c.chen@linux.intel.com, jonathan.cameron@huawei.com, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Juri Lelli <juri.lelli@redhat.com>, Vincent Guittot <vincent.guittot@linaro.org>, Dietmar Eggemann <dietmar.eggemann@arm.com>, Steven Rostedt <rostedt@goodmis.org>, Ben Segall <bsegall@google.com>, Mel Gorman <mgorman@suse.de>, Daniel Bristot de Oliveira <bristot@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Linus Walleij <linus.walleij@linaro.org>, Geert Uytterhoeven <geert+renesas@glider.be>, Andrew Morton <akpm@linux-foundation.org>, Anshuman Khandual <anshuman.khandual@arm.com>, Mike Rapoport <rppt@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ardb@kernel.org>, YiFei Zhu <yifeifz2@illinois.edu>, =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?= <u.kleine-koenig@pengutronix.de>, Kefeng Wang <wangkefeng.wang@huawei.com>, Sergei Trofimovich <slyfox@gentoo.org>, David Hildenbrand <david@redhat.com>, Randy Dunlap <rdunlap@infradead.org>, Masahiro Yamada <masahiroy@kernel.org>, Kees Cook <keescook@chromium.org>, Nathan Chancellor <nathan@kernel.org>, Nick Desaulniers <ndesaulniers@google.com>, Chris Down <chris@chrisdown.name>, Vipin Sharma <vipinsh@google.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Daniel Borkmann <daniel@iogearbox.net>, Vlastimil Babka <vbabka@suse.cz>, Frederic Weisbecker <frederic@kernel.org>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>

Hi folks,

This stems from Barry introducing a new CONFIG_SCHED_CLUSTER which highlighted
the current state of similar Kconfigs isn't great:
  http://lore.kernel.org/r/CAGsJ_4xZD0sG0Df666f0bvHOzuPMjnw0dN_mArER5k1pJ6LPLw@mail.gmail.com

The changes happen all in one big patch; the alternative would be to have one
patch per arch that adds the ARCH_SUPPORTS_SCHED_* selection, then a final patch
that adds the generic definitions and removes the arch ones (which I can do if
that's a preferred approach).

Briefly tested by setting ARCH=foo and playing around with menuconfig.

Based on top of Peter's queue:
  git://git.kernel.org/pub/scm/linux/kernel/git/peterz/queue.git -b sched/next

Patches are also available at:
  https://git.gitlab.arm.com/linux-arm/linux-vs.git -b mainline/sched/topo_kconfig_cleanup

Cheers,
Valentin

Valentin Schneider (2):
  sched: Move Kconfig.preempt to sched/Kconfig
  sched: Centralize SCHED_{SMT, MC, CLUSTER} definitions

 arch/arm/Kconfig                          | 18 ++--------
 arch/arm64/Kconfig                        | 26 ++------------
 arch/ia64/Kconfig                         |  9 +----
 arch/mips/Kconfig                         | 10 +-----
 arch/parisc/Kconfig                       |  9 +----
 arch/powerpc/Kconfig                      |  9 +----
 arch/s390/Kconfig                         |  8 ++---
 arch/sh/Kconfig                           |  1 +
 arch/sh/mm/Kconfig                        |  9 -----
 arch/sparc/Kconfig                        | 20 ++---------
 arch/x86/Kconfig                          | 26 ++------------
 init/Kconfig                              |  2 +-
 kernel/{Kconfig.preempt => sched/Kconfig} | 41 +++++++++++++++++++++++
 13 files changed, 59 insertions(+), 129 deletions(-)
 rename kernel/{Kconfig.preempt => sched/Kconfig} (79%)

--
2.25.1
