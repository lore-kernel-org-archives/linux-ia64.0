From: Josh Poimboeuf <jpoimboe@kernel.org>
Date: Fri, 03 Feb 2023 22:05:09 +0000
Subject: [PATCH 00/22] cpu,sched: Mark arch_cpu_idle_dead() __noreturn
Message-Id: <cover.1675461757.git.jpoimboe@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: jgross@suse.com, richard.henderson@linaro.org, ink@jurassic.park.msu.ru, mattst88@gmail.com, linux-alpha@vger.kernel.org, linux@armlinux.org.uk, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will@kernel.org, guoren@kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, loongarch@lists.linux.dev, f.fainelli@gmail.com, bcm-kernel-feedback-list@broadcom.com, tsbogend@alpha.franken.de, linux-mips@vger.kernel.org, jiaxun.yang@flygoat.com, mpe@ellerman.id.au, npiggin@gmail.com, christophe.leroy@csgroup.eu, linuxppc-dev@lists.ozlabs.org, ysato@users.sourceforge.jp, dalias@libc.org, linux-sh@vger.kernel.org, davem@davemloft.net, sparclinux@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, x86@kernel.org, hpa@zytor.com, chris@zankel.net, jcmvbkbc@gmail.com, linux-xtensa@linux-xtensa.org, peterz@infradead.org, juri.lelli@redhat.com, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, bsegall@google.com, mgorman@suse.de, bristot@redhat.com, vschneid@redhat.com, paulmck@kernel.org

These are some minor changes to enable the __noreturn attribute for
arch_cpu_idle_dead().  (If there are no objections, I can merge the
entire set through the tip tree.)

Until recently [1], in Xen, when a previously offlined CPU was brought
back online, it unexpectedly resumed execution where it left off in the
middle of the idle loop by returning from play_dead() and its caller
arch_cpu_idle_dead().

There were some clever hacks to make that work, but the behavior was
surprising as do_idle() doesn't expect an offlined CPU to return from
the dead in the middle of the function.

Now that Xen has been fixed, make sure arch_cpu_idle_dead() never
returns by marking it __noreturn.  This causes the compiler to complain
if an arch-specific implementation might return.  It also improves code
generation for both caller and callee.

Patches 1-20 update the arch-specific implementations of the function so
they don't actually return (even in error cases), and make that visible
to the compiler.  That's typically done by ending the function with a
call to another noreturn function, or with a BUG().

Patch 21 fixes the weak implementation.

Patch 22 actually adds the __noreturn attribute.

[1] 076cbf5d2163 ("x86/xen: don't let xen_pv_play_dead() return")

Josh Poimboeuf (22):
  alpha/cpu: Expose arch_cpu_idle_dead()'s prototype declaration
  alpha/cpu: Make sure arch_cpu_idle_dead() doesn't return
  arm/cpu: Make sure arch_cpu_idle_dead() doesn't return
  arm64/cpu: Mark cpu_die() __noreturn
  csky/cpu: Make sure arch_cpu_idle_dead() doesn't return
  ia64/cpu: Mark play_dead() __noreturn
  loongarch/cpu: Make sure play_dead() doesn't return
  loongarch/cpu: Mark play_dead() __noreturn
  mips/cpu: Expose play_dead()'s prototype definition
  mips/cpu: Make sure play_dead() doesn't return
  mips/cpu: Mark play_dead() __noreturn
  powerpc/cpu: Mark start_secondary_resume() __noreturn
  sh/cpu: Make sure play_dead() doesn't return
  sh/cpu: Mark play_dead() __noreturn
  sh/cpu: Expose arch_cpu_idle_dead()'s prototype definition
  sparc/cpu: Mark cpu_play_dead() __noreturn
  x86/cpu: Make sure play_dead() doesn't return
  x86/cpu: Mark play_dead() __noreturn
  xtensa/cpu: Make sure cpu_die() doesn't return
  xtensa/cpu: Mark cpu_die() __noreturn
  sched/idle: Make sure weak version of arch_cpu_idle_dead() doesn't
    return
  sched/idle: Mark arch_cpu_idle_dead() __noreturn

 arch/alpha/kernel/process.c      | 2 ++
 arch/arm/kernel/smp.c            | 2 ++
 arch/arm64/include/asm/smp.h     | 2 +-
 arch/csky/kernel/smp.c           | 2 ++
 arch/ia64/kernel/process.c       | 4 ++--
 arch/loongarch/include/asm/smp.h | 2 +-
 arch/loongarch/kernel/smp.c      | 2 +-
 arch/mips/include/asm/smp.h      | 2 +-
 arch/mips/kernel/smp-bmips.c     | 3 +++
 arch/mips/loongson64/smp.c       | 1 +
 arch/powerpc/include/asm/smp.h   | 2 +-
 arch/sh/include/asm/smp-ops.h    | 5 +++--
 arch/sh/kernel/idle.c            | 1 +
 arch/sparc/include/asm/smp_64.h  | 2 +-
 arch/x86/include/asm/smp.h       | 3 ++-
 arch/x86/kernel/process.c        | 2 +-
 arch/xtensa/include/asm/smp.h    | 2 +-
 arch/xtensa/kernel/smp.c         | 2 ++
 include/linux/cpu.h              | 2 +-
 kernel/sched/idle.c              | 2 +-
 tools/objtool/check.c            | 1 +
 21 files changed, 31 insertions(+), 15 deletions(-)

-- 
2.39.0
