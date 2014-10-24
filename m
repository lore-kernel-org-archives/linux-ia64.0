From: Lennox Wu <lennox.wu@gmail.com>
Date: Fri, 24 Oct 2014 10:03:25 +0000
Subject: Re: [PATCH v2 08/47] kernel: Move pm_power_off to common code
Message-Id: <CAF0htA6Rj_Gk0p19r0sE69mUnSgq26jzPvKtqyYUDFyhOdc_9A@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1413864783-3271-1-git-send-email-linux@roeck-us.net>
 <1413864783-3271-9-git-send-email-linux@roeck-us.net>
In-Reply-To: <1413864783-3271-9-git-send-email-linux@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

Acked-by: Lennox Wu <lennox.wu@gmail.com>

2014-10-21 12:12 GMT+08:00 Guenter Roeck <linux@roeck-us.net>:
> pm_power_off is defined for all architectures. Move it to common code.
>
> Have all architectures call do_kernel_power_off instead of pm_power_off.
> Some architectures point pm_power_off to machine_power_off. For those,
> call do_kernel_power_off from machine_power_off instead.
>
> Acked-by: David Vrabel <david.vrabel@citrix.com>
> Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>
> Acked-by: Hirokazu Takata <takata@linux-m32r.org>
> Acked-by: Jesper Nilsson <jesper.nilsson@axis.com>
> Acked-by: Max Filippov <jcmvbkbc@gmail.com>
> Acked-by: Rafael J. Wysocki <rjw@rjwysocki.net>
> Acked-by: Richard Weinberger <richard@nod.at>
> Acked-by: Xuetao Guan <gxt@mprc.pku.edu.cn>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> ---
> v2:
> - do_kernel_poweroff -> do_kernel_power_off
> - have_kernel_poweroff -> have_kernel_power_off
>
>  arch/alpha/kernel/process.c        |  9 +++------
>  arch/arc/kernel/reset.c            |  5 +----
>  arch/arm/kernel/process.c          |  5 +----
>  arch/arm64/kernel/process.c        |  5 +----
>  arch/avr32/kernel/process.c        |  6 +-----
>  arch/blackfin/kernel/process.c     |  3 ---
>  arch/blackfin/kernel/reboot.c      |  2 ++
>  arch/c6x/kernel/process.c          |  9 +--------
>  arch/cris/kernel/process.c         |  4 +---
>  arch/frv/kernel/process.c          |  5 ++---
>  arch/hexagon/kernel/reset.c        |  5 ++---
>  arch/ia64/kernel/process.c         |  5 +----
>  arch/m32r/kernel/process.c         |  8 ++++----
>  arch/m68k/kernel/process.c         |  6 +-----
>  arch/metag/kernel/process.c        |  6 +-----
>  arch/microblaze/kernel/process.c   |  3 ---
>  arch/microblaze/kernel/reset.c     |  1 +
>  arch/mips/kernel/reset.c           |  6 +-----
>  arch/mn10300/kernel/process.c      |  8 ++------
>  arch/openrisc/kernel/process.c     |  8 +++++---
>  arch/parisc/kernel/process.c       |  8 ++++----
>  arch/powerpc/kernel/setup-common.c |  6 +++---
>  arch/s390/kernel/setup.c           |  8 ++------
>  arch/score/kernel/process.c        |  8 ++++----
>  arch/sh/kernel/reboot.c            |  6 +-----
>  arch/sparc/kernel/process_32.c     | 10 ++--------
>  arch/sparc/kernel/reboot.c         |  8 ++------
>  arch/tile/kernel/reboot.c          |  7 +++----
>  arch/um/kernel/reboot.c            |  2 --
>  arch/unicore32/kernel/process.c    |  9 +--------
>  arch/x86/kernel/reboot.c           | 11 +++--------
>  arch/x86/xen/enlighten.c           |  3 +--
>  arch/xtensa/kernel/process.c       |  4 ----
>  drivers/parisc/power.c             |  3 +--
>  kernel/power/poweroff_handler.c    |  8 ++++++++
>  kernel/reboot.c                    |  4 ++--
>  36 files changed, 68 insertions(+), 146 deletions(-)
>
> diff --git a/arch/alpha/kernel/process.c b/arch/alpha/kernel/process.c
> index 1941a07..81c43f8 100644
> --- a/arch/alpha/kernel/process.c
> +++ b/arch/alpha/kernel/process.c
> @@ -24,6 +24,7 @@
>  #include <linux/vt.h>
>  #include <linux/mman.h>
>  #include <linux/elfcore.h>
> +#include <linux/pm.h>
>  #include <linux/reboot.h>
>  #include <linux/tty.h>
>  #include <linux/console.h>
> @@ -40,12 +41,6 @@
>  #include "proto.h"
>  #include "pci_impl.h"
>
> -/*
> - * Power off function, if any
> - */
> -void (*pm_power_off)(void) = machine_power_off;
> -EXPORT_SYMBOL(pm_power_off);
> -
>  #ifdef CONFIG_ALPHA_WTINT
>  /*
>   * Sleep the CPU.
> @@ -184,6 +179,8 @@ machine_halt(void)
>  void
>  machine_power_off(void)
>  {
> +       do_kernel_power_off();
> +
>         common_shutdown(LINUX_REBOOT_CMD_POWER_OFF, NULL);
>  }
>
> diff --git a/arch/arc/kernel/reset.c b/arch/arc/kernel/reset.c
> index 2768fa1..0758d9d 100644
> --- a/arch/arc/kernel/reset.c
> +++ b/arch/arc/kernel/reset.c
> @@ -26,9 +26,6 @@ void machine_restart(char *__unused)
>
>  void machine_power_off(void)
>  {
> -       /* FIXME ::  power off ??? */
> +       do_kernel_power_off();
>         machine_halt();
>  }
> -
> -void (*pm_power_off) (void) = NULL;
> -EXPORT_SYMBOL(pm_power_off);
> diff --git a/arch/arm/kernel/process.c b/arch/arm/kernel/process.c
> index fe972a2..aa3f656 100644
> --- a/arch/arm/kernel/process.c
> +++ b/arch/arm/kernel/process.c
> @@ -117,8 +117,6 @@ void soft_restart(unsigned long addr)
>  /*
>   * Function pointers to optional machine specific functions
>   */
> -void (*pm_power_off)(void);
> -EXPORT_SYMBOL(pm_power_off);
>
>  void (*arm_pm_restart)(enum reboot_mode reboot_mode, const char *cmd);
>
> @@ -205,8 +203,7 @@ void machine_power_off(void)
>         local_irq_disable();
>         smp_send_stop();
>
> -       if (pm_power_off)
> -               pm_power_off();
> +       do_kernel_power_off();
>  }
>
>  /*
> diff --git a/arch/arm64/kernel/process.c b/arch/arm64/kernel/process.c
> index c3065db..46a483a 100644
> --- a/arch/arm64/kernel/process.c
> +++ b/arch/arm64/kernel/process.c
> @@ -68,8 +68,6 @@ void soft_restart(unsigned long addr)
>  /*
>   * Function pointers to optional machine specific functions
>   */
> -void (*pm_power_off)(void);
> -EXPORT_SYMBOL_GPL(pm_power_off);
>
>  void (*arm_pm_restart)(enum reboot_mode reboot_mode, const char *cmd);
>
> @@ -129,8 +127,7 @@ void machine_power_off(void)
>  {
>         local_irq_disable();
>         smp_send_stop();
> -       if (pm_power_off)
> -               pm_power_off();
> +       do_kernel_power_off();
>  }
>
>  /*
> diff --git a/arch/avr32/kernel/process.c b/arch/avr32/kernel/process.c
> index 42a53e74..529c1f6 100644
> --- a/arch/avr32/kernel/process.c
> +++ b/arch/avr32/kernel/process.c
> @@ -23,9 +23,6 @@
>
>  #include <mach/pm.h>
>
> -void (*pm_power_off)(void);
> -EXPORT_SYMBOL(pm_power_off);
> -
>  /*
>   * This file handles the architecture-dependent parts of process handling..
>   */
> @@ -48,8 +45,7 @@ void machine_halt(void)
>
>  void machine_power_off(void)
>  {
> -       if (pm_power_off)
> -               pm_power_off();
> +       do_kernel_power_off();
>  }
>
>  void machine_restart(char *cmd)
> diff --git a/arch/blackfin/kernel/process.c b/arch/blackfin/kernel/process.c
> index 4aa5545..812dd83 100644
> --- a/arch/blackfin/kernel/process.c
> +++ b/arch/blackfin/kernel/process.c
> @@ -39,9 +39,6 @@ int nr_l1stack_tasks;
>  void *l1_stack_base;
>  unsigned long l1_stack_len;
>
> -void (*pm_power_off)(void) = NULL;
> -EXPORT_SYMBOL(pm_power_off);
> -
>  /*
>   * The idle loop on BFIN
>   */
> diff --git a/arch/blackfin/kernel/reboot.c b/arch/blackfin/kernel/reboot.c
> index c4f50a3..387d610 100644
> --- a/arch/blackfin/kernel/reboot.c
> +++ b/arch/blackfin/kernel/reboot.c
> @@ -7,6 +7,7 @@
>   */
>
>  #include <linux/interrupt.h>
> +#include <linux/pm.h>
>  #include <asm/bfin-global.h>
>  #include <asm/reboot.h>
>  #include <asm/bfrom.h>
> @@ -106,6 +107,7 @@ void machine_halt(void)
>  __attribute__((weak))
>  void native_machine_power_off(void)
>  {
> +       do_kernel_power_off();
>         idle_with_irq_disabled();
>  }
>
> diff --git a/arch/c6x/kernel/process.c b/arch/c6x/kernel/process.c
> index 57d2ea8..edf7e5a 100644
> --- a/arch/c6x/kernel/process.c
> +++ b/arch/c6x/kernel/process.c
> @@ -27,12 +27,6 @@ void (*c6x_halt)(void);
>  extern asmlinkage void ret_from_fork(void);
>  extern asmlinkage void ret_from_kernel_thread(void);
>
> -/*
> - * power off function, if any
> - */
> -void (*pm_power_off)(void);
> -EXPORT_SYMBOL(pm_power_off);
> -
>  void arch_cpu_idle(void)
>  {
>         unsigned long tmp;
> @@ -73,8 +67,7 @@ void machine_halt(void)
>
>  void machine_power_off(void)
>  {
> -       if (pm_power_off)
> -               pm_power_off();
> +       do_kernel_power_off();
>         halt_loop();
>  }
>
> diff --git a/arch/cris/kernel/process.c b/arch/cris/kernel/process.c
> index b78498e..9ebd76b 100644
> --- a/arch/cris/kernel/process.c
> +++ b/arch/cris/kernel/process.c
> @@ -31,9 +31,6 @@
>
>  extern void default_idle(void);
>
> -void (*pm_power_off)(void);
> -EXPORT_SYMBOL(pm_power_off);
> -
>  void arch_cpu_idle(void)
>  {
>         default_idle();
> @@ -60,6 +57,7 @@ void machine_halt(void)
>
>  void machine_power_off(void)
>  {
> +       do_kernel_power_off();
>  }
>
>  /*
> diff --git a/arch/frv/kernel/process.c b/arch/frv/kernel/process.c
> index 5d40aeb77..502dabb 100644
> --- a/arch/frv/kernel/process.c
> +++ b/arch/frv/kernel/process.c
> @@ -42,9 +42,6 @@ asmlinkage void ret_from_kernel_thread(void);
>
>  #include <asm/pgalloc.h>
>
> -void (*pm_power_off)(void);
> -EXPORT_SYMBOL(pm_power_off);
> -
>  static void core_sleep_idle(void)
>  {
>  #ifdef LED_DEBUG_SLEEP
> @@ -107,6 +104,8 @@ void machine_power_off(void)
>         gdbstub_exit(0);
>  #endif
>
> +       do_kernel_power_off();
> +
>         for (;;);
>  }
>
> diff --git a/arch/hexagon/kernel/reset.c b/arch/hexagon/kernel/reset.c
> index 76483c1..6f607b6 100644
> --- a/arch/hexagon/kernel/reset.c
> +++ b/arch/hexagon/kernel/reset.c
> @@ -16,11 +16,13 @@
>   * 02110-1301, USA.
>   */
>
> +#include <linux/pm.h>
>  #include <linux/smp.h>
>  #include <asm/hexagon_vm.h>
>
>  void machine_power_off(void)
>  {
> +       do_kernel_power_off();
>         smp_send_stop();
>         __vmstop();
>  }
> @@ -32,6 +34,3 @@ void machine_halt(void)
>  void machine_restart(char *cmd)
>  {
>  }
> -
> -void (*pm_power_off)(void) = NULL;
> -EXPORT_SYMBOL(pm_power_off);
> diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
> index b515149..88121a2 100644
> --- a/arch/ia64/kernel/process.c
> +++ b/arch/ia64/kernel/process.c
> @@ -57,8 +57,6 @@ void (*ia64_mark_idle)(int);
>
>  unsigned long boot_option_idle_override = IDLE_NO_OVERRIDE;
>  EXPORT_SYMBOL(boot_option_idle_override);
> -void (*pm_power_off) (void);
> -EXPORT_SYMBOL(pm_power_off);
>
>  void
>  ia64_do_show_stack (struct unw_frame_info *info, void *arg)
> @@ -675,8 +673,7 @@ machine_halt (void)
>  void
>  machine_power_off (void)
>  {
> -       if (pm_power_off)
> -               pm_power_off();
> +       do_kernel_power_off();
>         machine_halt();
>  }
>
> diff --git a/arch/m32r/kernel/process.c b/arch/m32r/kernel/process.c
> index e69221d..65a037e 100644
> --- a/arch/m32r/kernel/process.c
> +++ b/arch/m32r/kernel/process.c
> @@ -23,6 +23,7 @@
>  #include <linux/fs.h>
>  #include <linux/slab.h>
>  #include <linux/module.h>
> +#include <linux/pm.h>
>  #include <linux/ptrace.h>
>  #include <linux/unistd.h>
>  #include <linux/hardirq.h>
> @@ -44,9 +45,6 @@ unsigned long thread_saved_pc(struct task_struct *tsk)
>         return tsk->thread.lr;
>  }
>
> -void (*pm_power_off)(void) = NULL;
> -EXPORT_SYMBOL(pm_power_off);
> -
>  void machine_restart(char *__unused)
>  {
>  #if defined(CONFIG_PLAT_MAPPI3)
> @@ -67,7 +65,9 @@ void machine_halt(void)
>
>  void machine_power_off(void)
>  {
> -       /* M32R_FIXME */
> +       do_kernel_power_off();
> +       for (;;)
> +               ;
>  }
>
>  void show_regs(struct pt_regs * regs)
> diff --git a/arch/m68k/kernel/process.c b/arch/m68k/kernel/process.c
> index afe3d6e..bbc0a63 100644
> --- a/arch/m68k/kernel/process.c
> +++ b/arch/m68k/kernel/process.c
> @@ -78,14 +78,10 @@ void machine_halt(void)
>
>  void machine_power_off(void)
>  {
> -       if (pm_power_off)
> -               pm_power_off();
> +       do_kernel_power_off();
>         for (;;);
>  }
>
> -void (*pm_power_off)(void) = machine_power_off;
> -EXPORT_SYMBOL(pm_power_off);
> -
>  void show_regs(struct pt_regs * regs)
>  {
>         printk("\n");
> diff --git a/arch/metag/kernel/process.c b/arch/metag/kernel/process.c
> index 483dff9..8d95773 100644
> --- a/arch/metag/kernel/process.c
> +++ b/arch/metag/kernel/process.c
> @@ -67,9 +67,6 @@ void arch_cpu_idle_dead(void)
>  }
>  #endif
>
> -void (*pm_power_off)(void);
> -EXPORT_SYMBOL(pm_power_off);
> -
>  void (*soc_restart)(char *cmd);
>  void (*soc_halt)(void);
>
> @@ -90,8 +87,7 @@ void machine_halt(void)
>
>  void machine_power_off(void)
>  {
> -       if (pm_power_off)
> -               pm_power_off();
> +       do_kernel_power_off();
>         smp_send_stop();
>         hard_processor_halt(HALT_OK);
>  }
> diff --git a/arch/microblaze/kernel/process.c b/arch/microblaze/kernel/process.c
> index b2dd371..0ebca36 100644
> --- a/arch/microblaze/kernel/process.c
> +++ b/arch/microblaze/kernel/process.c
> @@ -44,9 +44,6 @@ void show_regs(struct pt_regs *regs)
>                                 regs->msr, regs->ear, regs->esr, regs->fsr);
>  }
>
> -void (*pm_power_off)(void) = NULL;
> -EXPORT_SYMBOL(pm_power_off);
> -
>  void flush_thread(void)
>  {
>  }
> diff --git a/arch/microblaze/kernel/reset.c b/arch/microblaze/kernel/reset.c
> index fbe58c6..2c6b32c 100644
> --- a/arch/microblaze/kernel/reset.c
> +++ b/arch/microblaze/kernel/reset.c
> @@ -103,6 +103,7 @@ void machine_halt(void)
>  void machine_power_off(void)
>  {
>         pr_notice("Machine power off...\n");
> +       do_kernel_power_off();
>         while (1)
>                 ;
>  }
> diff --git a/arch/mips/kernel/reset.c b/arch/mips/kernel/reset.c
> index 07fc524..09e74d2 100644
> --- a/arch/mips/kernel/reset.c
> +++ b/arch/mips/kernel/reset.c
> @@ -21,9 +21,6 @@
>   */
>  void (*_machine_restart)(char *command);
>  void (*_machine_halt)(void);
> -void (*pm_power_off)(void);
> -
> -EXPORT_SYMBOL(pm_power_off);
>
>  void machine_restart(char *command)
>  {
> @@ -39,6 +36,5 @@ void machine_halt(void)
>
>  void machine_power_off(void)
>  {
> -       if (pm_power_off)
> -               pm_power_off();
> +       do_kernel_power_off();
>  }
> diff --git a/arch/mn10300/kernel/process.c b/arch/mn10300/kernel/process.c
> index 3707da5..c78b2eb 100644
> --- a/arch/mn10300/kernel/process.c
> +++ b/arch/mn10300/kernel/process.c
> @@ -20,6 +20,7 @@
>  #include <linux/user.h>
>  #include <linux/interrupt.h>
>  #include <linux/delay.h>
> +#include <linux/pm.h>
>  #include <linux/reboot.h>
>  #include <linux/percpu.h>
>  #include <linux/err.h>
> @@ -45,12 +46,6 @@ unsigned long thread_saved_pc(struct task_struct *tsk)
>  }
>
>  /*
> - * power off function, if any
> - */
> -void (*pm_power_off)(void);
> -EXPORT_SYMBOL(pm_power_off);
> -
> -/*
>   * On SMP it's slightly faster (but much more power-consuming!)
>   * to poll the ->work.need_resched flag instead of waiting for the
>   * cross-CPU IPI to arrive. Use this option with caution.
> @@ -93,6 +88,7 @@ void machine_power_off(void)
>  #ifdef CONFIG_KERNEL_DEBUGGER
>         gdbstub_exit(0);
>  #endif
> +       do_kernel_power_off();
>  }
>
>  void show_regs(struct pt_regs *regs)
> diff --git a/arch/openrisc/kernel/process.c b/arch/openrisc/kernel/process.c
> index 386af25..494afd2 100644
> --- a/arch/openrisc/kernel/process.c
> +++ b/arch/openrisc/kernel/process.c
> @@ -25,6 +25,7 @@
>  #include <linux/kernel.h>
>  #include <linux/module.h>
>  #include <linux/mm.h>
> +#include <linux/pm.h>
>  #include <linux/stddef.h>
>  #include <linux/unistd.h>
>  #include <linux/ptrace.h>
> @@ -51,7 +52,7 @@
>   */
>  struct thread_info *current_thread_info_set[NR_CPUS] = { &init_thread_info, };
>
> -void machine_restart(void)
> +void machine_restart(char *cmd)
>  {
>         printk(KERN_INFO "*** MACHINE RESTART ***\n");
>         __asm__("l.nop 1");
> @@ -72,11 +73,12 @@ void machine_halt(void)
>  void machine_power_off(void)
>  {
>         printk(KERN_INFO "*** MACHINE POWER OFF ***\n");
> +
> +       do_kernel_power_off();
> +
>         __asm__("l.nop 1");
>  }
>
> -void (*pm_power_off) (void) = machine_power_off;
> -
>  /*
>   * When a process does an "exec", machine state like FPU and debug
>   * registers need to be reset.  This is a hook function for that.
> diff --git a/arch/parisc/kernel/process.c b/arch/parisc/kernel/process.c
> index 0bbbf0d..3f5d14a 100644
> --- a/arch/parisc/kernel/process.c
> +++ b/arch/parisc/kernel/process.c
> @@ -41,6 +41,7 @@
>  #include <linux/fs.h>
>  #include <linux/module.h>
>  #include <linux/personality.h>
> +#include <linux/pm.h>
>  #include <linux/ptrace.h>
>  #include <linux/sched.h>
>  #include <linux/slab.h>
> @@ -133,7 +134,9 @@ void machine_power_off(void)
>         pdc_soft_power_button(0);
>
>         pdc_chassis_send_status(PDC_CHASSIS_DIRECT_SHUTDOWN);
> -
> +
> +       do_kernel_power_off();
> +
>         /* It seems we have no way to power the system off via
>          * software. The user has to press the button himself. */
>
> @@ -141,9 +144,6 @@ void machine_power_off(void)
>                "Please power this system off now.");
>  }
>
> -void (*pm_power_off)(void) = machine_power_off;
> -EXPORT_SYMBOL(pm_power_off);
> -
>  /*
>   * Free current thread data structures etc..
>   */
> diff --git a/arch/powerpc/kernel/setup-common.c b/arch/powerpc/kernel/setup-common.c
> index 1362cd6..5b7a851 100644
> --- a/arch/powerpc/kernel/setup-common.c
> +++ b/arch/powerpc/kernel/setup-common.c
> @@ -141,6 +141,9 @@ void machine_power_off(void)
>         machine_shutdown();
>         if (ppc_md.power_off)
>                 ppc_md.power_off();
> +
> +       do_kernel_power_off();
> +
>  #ifdef CONFIG_SMP
>         smp_send_stop();
>  #endif
> @@ -151,9 +154,6 @@ void machine_power_off(void)
>  /* Used by the G5 thermal driver */
>  EXPORT_SYMBOL_GPL(machine_power_off);
>
> -void (*pm_power_off)(void) = machine_power_off;
> -EXPORT_SYMBOL_GPL(pm_power_off);
> -
>  void machine_halt(void)
>  {
>         machine_shutdown();
> diff --git a/arch/s390/kernel/setup.c b/arch/s390/kernel/setup.c
> index e80d9ff..267e025 100644
> --- a/arch/s390/kernel/setup.c
> +++ b/arch/s390/kernel/setup.c
> @@ -263,13 +263,9 @@ void machine_power_off(void)
>                  */
>                 console_unblank();
>         _machine_power_off();
> -}
>
> -/*
> - * Dummy power off function.
> - */
> -void (*pm_power_off)(void) = machine_power_off;
> -EXPORT_SYMBOL_GPL(pm_power_off);
> +       do_kernel_power_off();
> +}
>
>  static int __init early_parse_mem(char *p)
>  {
> diff --git a/arch/score/kernel/process.c b/arch/score/kernel/process.c
> index a1519ad3..b76ea67 100644
> --- a/arch/score/kernel/process.c
> +++ b/arch/score/kernel/process.c
> @@ -29,9 +29,6 @@
>  #include <linux/pm.h>
>  #include <linux/rcupdate.h>
>
> -void (*pm_power_off)(void);
> -EXPORT_SYMBOL(pm_power_off);
> -
>  /* If or when software machine-restart is implemented, add code here. */
>  void machine_restart(char *command) {}
>
> @@ -39,7 +36,10 @@ void machine_restart(char *command) {}
>  void machine_halt(void) {}
>
>  /* If or when software machine-power-off is implemented, add code here. */
> -void machine_power_off(void) {}
> +void machine_power_off(void)
> +{
> +       do_kernel_power_off();
> +}
>
>  void ret_from_fork(void);
>  void ret_from_kernel_thread(void);
> diff --git a/arch/sh/kernel/reboot.c b/arch/sh/kernel/reboot.c
> index 04afe5b..065de12 100644
> --- a/arch/sh/kernel/reboot.c
> +++ b/arch/sh/kernel/reboot.c
> @@ -11,9 +11,6 @@
>  #include <asm/tlbflush.h>
>  #include <asm/traps.h>
>
> -void (*pm_power_off)(void);
> -EXPORT_SYMBOL(pm_power_off);
> -
>  #ifdef CONFIG_SUPERH32
>  static void watchdog_trigger_immediate(void)
>  {
> @@ -51,8 +48,7 @@ static void native_machine_shutdown(void)
>
>  static void native_machine_power_off(void)
>  {
> -       if (pm_power_off)
> -               pm_power_off();
> +       do_kernel_power_off();
>  }
>
>  static void native_machine_halt(void)
> diff --git a/arch/sparc/kernel/process_32.c b/arch/sparc/kernel/process_32.c
> index 50e7b62..cb8148a 100644
> --- a/arch/sparc/kernel/process_32.c
> +++ b/arch/sparc/kernel/process_32.c
> @@ -48,14 +48,6 @@
>   */
>  void (*sparc_idle)(void);
>
> -/*
> - * Power-off handler instantiation for pm.h compliance
> - * This is done via auxio, but could be used as a fallback
> - * handler when auxio is not present-- unused for now...
> - */
> -void (*pm_power_off)(void) = machine_power_off;
> -EXPORT_SYMBOL(pm_power_off);
> -
>  /*
>   * sysctl - toggle power-off restriction for serial console
>   * systems in machine_power_off()
> @@ -112,6 +104,8 @@ void machine_power_off(void)
>                 sbus_writeb(power_register, auxio_power_register);
>         }
>
> +       do_kernel_power_off();
> +
>         machine_halt();
>  }
>
> diff --git a/arch/sparc/kernel/reboot.c b/arch/sparc/kernel/reboot.c
> index eba7d91..3c0bb03 100644
> --- a/arch/sparc/kernel/reboot.c
> +++ b/arch/sparc/kernel/reboot.c
> @@ -16,17 +16,13 @@
>   */
>  int scons_pwroff = 1;
>
> -/* This isn't actually used, it exists merely to satisfy the
> - * reference in kernel/sys.c
> - */
> -void (*pm_power_off)(void) = machine_power_off;
> -EXPORT_SYMBOL(pm_power_off);
> -
>  void machine_power_off(void)
>  {
>         if (strcmp(of_console_device->type, "serial") || scons_pwroff)
>                 prom_halt_power_off();
>
> +       do_kernel_power_off();
> +
>         prom_halt();
>  }
>
> diff --git a/arch/tile/kernel/reboot.c b/arch/tile/kernel/reboot.c
> index 6c5d2c0..8ff4a7f 100644
> --- a/arch/tile/kernel/reboot.c
> +++ b/arch/tile/kernel/reboot.c
> @@ -36,6 +36,9 @@ void machine_power_off(void)
>  {
>         arch_local_irq_disable_all();
>         smp_send_stop();
> +
> +       do_kernel_power_off();
> +
>         hv_power_off();
>  }
>
> @@ -45,7 +48,3 @@ void machine_restart(char *cmd)
>         smp_send_stop();
>         hv_restart((HV_VirtAddr) "vmlinux", (HV_VirtAddr) cmd);
>  }
> -
> -/* No interesting distinction to be made here. */
> -void (*pm_power_off)(void) = NULL;
> -EXPORT_SYMBOL(pm_power_off);
> diff --git a/arch/um/kernel/reboot.c b/arch/um/kernel/reboot.c
> index ced8903..a82ef28 100644
> --- a/arch/um/kernel/reboot.c
> +++ b/arch/um/kernel/reboot.c
> @@ -11,8 +11,6 @@
>  #include <os.h>
>  #include <skas.h>
>
> -void (*pm_power_off)(void);
> -
>  static void kill_off_processes(void)
>  {
>         if (proc_mm)
> diff --git a/arch/unicore32/kernel/process.c b/arch/unicore32/kernel/process.c
> index b008e99..9490dd5 100644
> --- a/arch/unicore32/kernel/process.c
> +++ b/arch/unicore32/kernel/process.c
> @@ -56,16 +56,9 @@ void machine_halt(void)
>         gpio_set_value(GPO_SOFT_OFF, 0);
>  }
>
> -/*
> - * Function pointers to optional machine specific functions
> - */
> -void (*pm_power_off)(void) = NULL;
> -EXPORT_SYMBOL(pm_power_off);
> -
>  void machine_power_off(void)
>  {
> -       if (pm_power_off)
> -               pm_power_off();
> +       do_kernel_power_off();
>         machine_halt();
>  }
>
> diff --git a/arch/x86/kernel/reboot.c b/arch/x86/kernel/reboot.c
> index 17962e6..5c09e28 100644
> --- a/arch/x86/kernel/reboot.c
> +++ b/arch/x86/kernel/reboot.c
> @@ -30,12 +30,6 @@
>  #include <asm/x86_init.h>
>  #include <asm/efi.h>
>
> -/*
> - * Power off function, if any
> - */
> -void (*pm_power_off)(void);
> -EXPORT_SYMBOL(pm_power_off);
> -
>  static const struct desc_ptr no_idt = {};
>
>  /*
> @@ -647,11 +641,12 @@ static void native_machine_halt(void)
>
>  static void native_machine_power_off(void)
>  {
> -       if (pm_power_off) {
> +       if (have_kernel_power_off()) {
>                 if (!reboot_force)
>                         machine_shutdown();
> -               pm_power_off();
> +               do_kernel_power_off();
>         }
> +
>         /* A fallback in case there is no PM info available */
>         tboot_shutdown(TB_SHUTDOWN_HALT);
>  }
> diff --git a/arch/x86/xen/enlighten.c b/arch/x86/xen/enlighten.c
> index 1a3f044..c2c1d74 100644
> --- a/arch/x86/xen/enlighten.c
> +++ b/arch/x86/xen/enlighten.c
> @@ -1320,8 +1320,7 @@ static void xen_machine_halt(void)
>
>  static void xen_machine_power_off(void)
>  {
> -       if (pm_power_off)
> -               pm_power_off();
> +       do_kernel_power_off();
>         xen_reboot(SHUTDOWN_poweroff);
>  }
>
> diff --git a/arch/xtensa/kernel/process.c b/arch/xtensa/kernel/process.c
> index 1c85323..c487296 100644
> --- a/arch/xtensa/kernel/process.c
> +++ b/arch/xtensa/kernel/process.c
> @@ -49,10 +49,6 @@ extern void ret_from_kernel_thread(void);
>
>  struct task_struct *current_set[NR_CPUS] = {&init_task, };
>
> -void (*pm_power_off)(void) = NULL;
> -EXPORT_SYMBOL(pm_power_off);
> -
> -
>  #if XTENSA_HAVE_COPROCESSORS
>
>  void coprocessor_release_all(struct thread_info *ti)
> diff --git a/drivers/parisc/power.c b/drivers/parisc/power.c
> index ef31b77..f10cf92 100644
> --- a/drivers/parisc/power.c
> +++ b/drivers/parisc/power.c
> @@ -95,8 +95,7 @@ static void process_shutdown(void)
>                 /* send kill signal */
>                 if (kill_cad_pid(SIGINT, 1)) {
>                         /* just in case killing init process failed */
> -                       if (pm_power_off)
> -                               pm_power_off();
> +                       kernel_power_off();
>                 }
>         }
>  }
> diff --git a/kernel/power/poweroff_handler.c b/kernel/power/poweroff_handler.c
> index aeb4736..37f0b88 100644
> --- a/kernel/power/poweroff_handler.c
> +++ b/kernel/power/poweroff_handler.c
> @@ -22,6 +22,12 @@
>  #include <linux/types.h>
>
>  /*
> + * If set, calling this function will power off the system immediately.
> + */
> +void (*pm_power_off)(void);
> +EXPORT_SYMBOL(pm_power_off);
> +
> +/*
>   *     Notifier list for kernel code which wants to be called
>   *     to power off the system.
>   */
> @@ -236,6 +242,8 @@ EXPORT_SYMBOL(devm_register_power_off_handler);
>  void do_kernel_power_off(void)
>  {
>         spin_lock(&power_off_handler_lock);
> +       if (pm_power_off)
> +               pm_power_off();
>         raw_notifier_call_chain(&power_off_handler_list, 0, NULL);
>         spin_unlock(&power_off_handler_lock);
>  }
> diff --git a/kernel/reboot.c b/kernel/reboot.c
> index 5925f5a..0930851 100644
> --- a/kernel/reboot.c
> +++ b/kernel/reboot.c
> @@ -306,9 +306,9 @@ SYSCALL_DEFINE4(reboot, int, magic1, int, magic2, unsigned int, cmd,
>                 return ret;
>
>         /* Instead of trying to make the power_off code look like
> -        * halt when pm_power_off is not set do it the easy way.
> +        * halt when no poweroff handler exists do it the easy way.
>          */
> -       if ((cmd = LINUX_REBOOT_CMD_POWER_OFF) && !pm_power_off)
> +       if (cmd = LINUX_REBOOT_CMD_POWER_OFF && !have_kernel_power_off())
>                 cmd = LINUX_REBOOT_CMD_HALT;
>
>         mutex_lock(&reboot_mutex);
> --
> 1.9.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
