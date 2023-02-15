From: "Paul E. McKenney" <paulmck@kernel.org>
Date: Wed, 15 Feb 2023 22:22:49 +0000
Subject: Re: [PATCH v2 00/24] cpu,sched: Mark arch_cpu_idle_dead() __noreturn
Message-Id: <20230215222249.GM2948950@paulmck-ThinkPad-P17-Gen-1>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1676358308.git.jpoimboe@kernel.org>
In-Reply-To: <cover.1676358308.git.jpoimboe@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Josh Poimboeuf <jpoimboe@kernel.org>
Cc: linux-kernel@vger.kernel.org, jgross@suse.com, richard.henderson@linaro.org, ink@jurassic.park.msu.ru, mattst88@gmail.com, linux-alpha@vger.kernel.org, linux@armlinux.org.uk, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will@kernel.org, guoren@kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, loongarch@lists.linux.dev, f.fainelli@gmail.com, bcm-kernel-feedback-list@broadcom.com, tsbogend@alpha.franken.de, linux-mips@vger.kernel.org, jiaxun.yang@flygoat.com, mpe@ellerman.id.au, npiggin@gmail.com, christophe.leroy@csgroup.eu, linuxppc-dev@lists.ozlabs.org, ysato@users.sourceforge.jp, dalias@libc.org, linux-sh@vger.kernel.org, davem@davemloft.net, sparclinux@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, x86@kernel.org, hpa@zytor.com, chris@zankel.net, jcmvbkbc@gmail.com, linux-xtensa@linux-xtensa.org, peterz@infradead.org, juri.lelli@redhat.com, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, bsegall@google.com, mgorman@suse.de, bristot@redhat.com, vschneid@redhat.com

On Mon, Feb 13, 2023 at 11:05:34PM -0800, Josh Poimboeuf wrote:
> v2:
> - make arch_call_rest_init() and rest_init() __noreturn
> - make objtool 'global_returns' work for weak functions
> - rebase on tip/objtool/core with dependencies merged in (mingo)
> - add acks
> 
> v1.1:
> - add __noreturn to all arch_cpu_idle_dead() implementations (mpe)

With this, rcutorture no longer gets objtool complaints on x86, thank you!

Tested-by: Paul E. McKenney <paulmck@kernel.org>

> Josh Poimboeuf (24):
>   alpha/cpu: Expose arch_cpu_idle_dead()'s prototype declaration
>   alpha/cpu: Make sure arch_cpu_idle_dead() doesn't return
>   arm/cpu: Make sure arch_cpu_idle_dead() doesn't return
>   arm64/cpu: Mark cpu_die() __noreturn
>   csky/cpu: Make sure arch_cpu_idle_dead() doesn't return
>   ia64/cpu: Mark play_dead() __noreturn
>   loongarch/cpu: Make sure play_dead() doesn't return
>   loongarch/cpu: Mark play_dead() __noreturn
>   mips/cpu: Expose play_dead()'s prototype definition
>   mips/cpu: Make sure play_dead() doesn't return
>   mips/cpu: Mark play_dead() __noreturn
>   powerpc/cpu: Mark start_secondary_resume() __noreturn
>   sh/cpu: Make sure play_dead() doesn't return
>   sh/cpu: Mark play_dead() __noreturn
>   sh/cpu: Expose arch_cpu_idle_dead()'s prototype definition
>   sparc/cpu: Mark cpu_play_dead() __noreturn
>   x86/cpu: Make sure play_dead() doesn't return
>   x86/cpu: Mark play_dead() __noreturn
>   xtensa/cpu: Make sure cpu_die() doesn't return
>   xtensa/cpu: Mark cpu_die() __noreturn
>   sched/idle: Make sure weak version of arch_cpu_idle_dead() doesn't
>     return
>   objtool: Include weak functions in 'global_noreturns' check
>   init: Make arch_call_rest_init() and rest_init() __noreturn
>   sched/idle: Mark arch_cpu_idle_dead() __noreturn
> 
>  arch/alpha/kernel/process.c      |  4 +++-
>  arch/arm/kernel/smp.c            |  4 +++-
>  arch/arm64/include/asm/smp.h     |  2 +-
>  arch/arm64/kernel/process.c      |  2 +-
>  arch/csky/kernel/smp.c           |  4 +++-
>  arch/ia64/kernel/process.c       |  6 +++---
>  arch/loongarch/include/asm/smp.h |  2 +-
>  arch/loongarch/kernel/process.c  |  2 +-
>  arch/loongarch/kernel/smp.c      |  2 +-
>  arch/mips/include/asm/smp.h      |  2 +-
>  arch/mips/kernel/process.c       |  2 +-
>  arch/mips/kernel/smp-bmips.c     |  3 +++
>  arch/mips/loongson64/smp.c       |  1 +
>  arch/parisc/kernel/process.c     |  2 +-
>  arch/powerpc/include/asm/smp.h   |  2 +-
>  arch/powerpc/kernel/smp.c        |  2 +-
>  arch/riscv/kernel/cpu-hotplug.c  |  2 +-
>  arch/s390/kernel/idle.c          |  2 +-
>  arch/s390/kernel/setup.c         |  2 +-
>  arch/sh/include/asm/smp-ops.h    |  5 +++--
>  arch/sh/kernel/idle.c            |  3 ++-
>  arch/sparc/include/asm/smp_64.h  |  2 +-
>  arch/sparc/kernel/process_64.c   |  2 +-
>  arch/x86/include/asm/smp.h       |  3 ++-
>  arch/x86/kernel/process.c        |  4 ++--
>  arch/xtensa/include/asm/smp.h    |  2 +-
>  arch/xtensa/kernel/smp.c         |  4 +++-
>  include/linux/cpu.h              |  2 +-
>  include/linux/start_kernel.h     |  4 ++--
>  init/main.c                      |  4 ++--
>  kernel/sched/idle.c              |  2 +-
>  tools/objtool/check.c            | 11 +++++++----
>  32 files changed, 57 insertions(+), 39 deletions(-)
> 
> -- 
> 2.39.1
> 
