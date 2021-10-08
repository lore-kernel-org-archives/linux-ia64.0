From: Valentin Schneider <valentin.schneider@arm.com>
Date: Fri, 08 Oct 2021 11:53:46 +0000
Subject: [PATCH 1/2] sched: Move Kconfig.preempt to sched/Kconfig
Message-Id: <20211008115347.425234-2-valentin.schneider@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211008115347.425234-1-valentin.schneider@arm.com>
In-Reply-To: <20211008115347.425234-1-valentin.schneider@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org
Cc: Peter Zijlstra <peterz@infradead.org>, aubrey.li@linux.intel.com, song.bao.hua@hisilicon.com, tim.c.chen@linux.intel.com, jonathan.cameron@huawei.com, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Juri Lelli <juri.lelli@redhat.com>, Vincent Guittot <vincent.guittot@linaro.org>, Dietmar Eggemann <dietmar.eggemann@arm.com>, Steven Rostedt <rostedt@goodmis.org>, Ben Segall <bsegall@google.com>, Mel Gorman <mgorman@suse.de>, Daniel Bristot de Oliveira <bristot@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Linus Walleij <linus.walleij@linaro.org>, Geert Uytterhoeven <geert+renesas@glider.be>, Andrew Morton <akpm@linux-foundation.org>, Anshuman Khandual <anshuman.khandual@arm.com>, Mike Rapoport <rppt@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ardb@kernel.org>, YiFei Zhu <yifeifz2@illinois.edu>, =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?= <u.kleine-koenig@pengutronix.de>, Kefeng Wang <wangkefeng.wang@huawei.com>, Sergei Trofimovich <slyfox@gentoo.org>, David Hildenbrand <david@redhat.com>, Randy Dunlap <rdunlap@infradead.org>, Masahiro Yamada <masahiroy@kernel.org>, Kees Cook <keescook@chromium.org>, Nathan Chancellor <nathan@kernel.org>, Nick Desaulniers <ndesaulniers@google.com>, Chris Down <chris@chrisdown.name>, Vipin Sharma <vipinsh@google.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Daniel Borkmann <daniel@iogearbox.net>, Vlastimil Babka <vbabka@suse.cz>, Frederic Weisbecker <frederic@kernel.org>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>

Kconfig.preempt already contains more than just preemption configs (see
CONFIG_SCHED_CORE), and a subsequent patch will introduce more
scheduler-specific configs.

Move the file to the scheduler directory.

Suggested-by: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Valentin Schneider <valentin.schneider@arm.com>
---
 init/Kconfig                              | 2 +-
 kernel/{Kconfig.preempt => sched/Kconfig} | 2 --
 2 files changed, 1 insertion(+), 3 deletions(-)
 rename kernel/{Kconfig.preempt => sched/Kconfig} (99%)

diff --git a/init/Kconfig b/init/Kconfig
index 11f8a845f259..4caedc821b06 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -460,7 +460,7 @@ config AUDITSYSCALL
 source "kernel/irq/Kconfig"
 source "kernel/time/Kconfig"
 source "kernel/bpf/Kconfig"
-source "kernel/Kconfig.preempt"
+source "kernel/sched/Kconfig"
 
 menu "CPU/Task time and stats accounting"
 
diff --git a/kernel/Kconfig.preempt b/kernel/sched/Kconfig
similarity index 99%
rename from kernel/Kconfig.preempt
rename to kernel/sched/Kconfig
index 60f1bfc3c7b2..c8b8e12c9c9c 100644
--- a/kernel/Kconfig.preempt
+++ b/kernel/sched/Kconfig
@@ -131,5 +131,3 @@ config SCHED_CORE
 	  SCHED_CORE is default disabled. When it is enabled and unused,
 	  which is the likely usage by Linux distributions, there should
 	  be no measurable impact on performance.
-
-
-- 
2.25.1
