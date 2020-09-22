From: "Paul E. McKenney" <paulmck@kernel.org>
Date: Tue, 22 Sep 2020 21:56:51 +0000
Subject: Re: [PATCH] RCU: export rcu_idle_enter/_exit for loadable modules
Message-Id: <20200922215651.GE29330@paulmck-ThinkPad-P72>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200922214331.26608-1-rdunlap@infradead.org>
In-Reply-To: <20200922214331.26608-1-rdunlap@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Randy Dunlap <rdunlap@infradead.org>
Cc: linux-kernel@vger.kernel.org, kernel test robot <lkp@intel.com>, "Rafael J . Wysocki" <rjw@rjwysocki.net>, linux-acpi@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>, rcu@vger.kernel.org

On Tue, Sep 22, 2020 at 02:43:30PM -0700, Randy Dunlap wrote:
> drivers/acpi/processor.ko uses rcu_idle_enter()/_exit() but
> they are not exported. This causes build errors on IA64,
> so export those 2 functions.
> 
> ERROR: modpost: "rcu_idle_enter" [drivers/acpi/processor.ko] undefined!
> ERROR: modpost: "rcu_idle_exit" [drivers/acpi/processor.ko] undefined!
> 
> Reported-by: kernel test robot <lkp@intel.com>
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
> Cc: Rafael J. Wysocki <rjw@rjwysocki.net>
> Cc: linux-acpi@vger.kernel.org
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Fenghua Yu <fenghua.yu@intel.com>
> Cc: linux-ia64@vger.kernel.org
> Cc: "Paul E. McKenney" <paulmck@kernel.org>
> Cc: Josh Triplett <josh@joshtriplett.org>
> Cc: rcu@vger.kernel.org
> ---
> Is there a problem with exporting these functions for use by
> loadable modules?  If so, this driver should be modified not
> to use rcu_idle_enter/exit.

Good catch, but Borislav Petkov beat you to it:

https://lore.kernel.org/lkml/20200921103741.GC5901@zn.tnic/

Rafael has applied Borislav's patch to his cpuidle tree for v5.9-rc7.

							Thanx, Paul

>  kernel/rcu/tree.c |    2 ++
>  1 file changed, 2 insertions(+)
> 
> --- lnx-59-rc6.orig/kernel/rcu/tree.c
> +++ lnx-59-rc6/kernel/rcu/tree.c
> @@ -673,6 +673,7 @@ void rcu_idle_enter(void)
>  	lockdep_assert_irqs_disabled();
>  	rcu_eqs_enter(false);
>  }
> +EXPORT_SYMBOL_GPL(rcu_idle_enter);
>  
>  #ifdef CONFIG_NO_HZ_FULL
>  /**
> @@ -886,6 +887,7 @@ void rcu_idle_exit(void)
>  	rcu_eqs_exit(false);
>  	local_irq_restore(flags);
>  }
> +EXPORT_SYMBOL_GPL(rcu_idle_exit);
>  
>  #ifdef CONFIG_NO_HZ_FULL
>  /**
