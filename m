From: Jay Lan <jlan@sgi.com>
Date: Tue, 08 Apr 2008 17:36:10 +0000
Subject: Re: [PATCH 1/2] ia64 kdump: add kdump_on_fatal_mca
Message-Id: <47FBAD0A.5080701@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <47FAF533.8010707@jp.fujitsu.com>
In-Reply-To: <47FAF533.8010707@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hidetoshi Seto wrote:
> While it is convenient that we can invoke kdump by asserting INIT
> via button on chassis etc., there are some situations that invoking
> kdump on fatal MCA is not welcomed rather than rebooting fast without
> dump.
> 
> This patch adds a new flag 'kdump_on_fatal_mca' that is independent
> from 'kdump_on_init' currently available.  Adding this flag enable
> us to turning on/off of kdump depend on the event, INIT and/or fatal
> MCA.
> 
> Thanks,
> H.Seto
> 
> Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
> 
> ---
>  arch/ia64/kernel/crash.c |   31 +++++++++++++++++++++++--------
>  arch/ia64/kernel/mca.c   |    6 +-----
>  2 files changed, 24 insertions(+), 13 deletions(-)
> 
> Index: GIT-torvalds/arch/ia64/kernel/crash.c
> =================================> --- GIT-torvalds.orig/arch/ia64/kernel/crash.c
> +++ GIT-torvalds/arch/ia64/kernel/crash.c
> @@ -24,6 +24,7 @@ int kdump_status[NR_CPUS];
>  static atomic_t kdump_cpu_frozen;
>  atomic_t kdump_in_progress;
>  static int kdump_on_init = 1;
> +static int kdump_on_fatal_mca = 0;

I think kdump_on_fatal_mca should be set to 1 by default. Fatal
mca is exactly the case where we need a dump to analyze the problem.

Thanhks,
 - jay

> 
>  static inline Elf64_Word
>  *append_elf_note(Elf64_Word *buf, char *name, unsigned type, void *data,
> @@ -148,7 +149,7 @@ kdump_init_notifier(struct notifier_bloc
>  	struct ia64_mca_notify_die *nd;
>  	struct die_args *args = data;
> 
> -	if (!kdump_on_init)
> +	if (!kdump_on_init && !kdump_on_fatal_mca)
>  		return NOTIFY_DONE;
> 
>  	if (!ia64_kimage) {
> @@ -174,11 +175,14 @@ kdump_init_notifier(struct notifier_bloc
> 
>  	switch (val) {
>  		case DIE_INIT_MONARCH_PROCESS:
> -			atomic_set(&kdump_in_progress, 1);
> -			*(nd->monarch_cpu) = -1;
> +			if (kdump_on_init) {
> +				atomic_set(&kdump_in_progress, 1);
> +				*(nd->monarch_cpu) = -1;
> +			}
>  			break;
>  		case DIE_INIT_MONARCH_LEAVE:
> -			machine_kdump_on_init();
> +			if (kdump_on_init)
> +				machine_kdump_on_init();
>  			break;
>  		case DIE_INIT_SLAVE_LEAVE:
>  			if (atomic_read(&kdump_in_progress))
> @@ -189,16 +193,19 @@ kdump_init_notifier(struct notifier_bloc
>  				unw_init_running(kdump_cpu_freeze, NULL);
>  			break;
>  		case DIE_MCA_MONARCH_LEAVE:
> -		     /* die_register->signr indicate if MCA is recoverable */
> -			if (!args->signr)
> +			/* die_register->signr indicate if MCA is recoverable */
> +			if (kdump_on_fatal_mca && !args->signr) {
> +				atomic_set(&kdump_in_progress, 1);
> +				*(nd->monarch_cpu) = -1;
>  				machine_kdump_on_init();
> +			}
>  			break;
>  	}
>  	return NOTIFY_DONE;
>  }
> 
>  #ifdef CONFIG_SYSCTL
> -static ctl_table kdump_on_init_table[] = {
> +static ctl_table kdump_ctl_table[] = {
>  	{
>  		.ctl_name = CTL_UNNUMBERED,
>  		.procname = "kdump_on_init",
> @@ -207,6 +214,14 @@ static ctl_table kdump_on_init_table[] >  		.mode = 0644,
>  		.proc_handler = &proc_dointvec,
>  	},
> +	{
> +		.ctl_name = CTL_UNNUMBERED,
> +		.procname = "kdump_on_fatal_mca",
> +		.data = &kdump_on_fatal_mca,
> +		.maxlen = sizeof(int),
> +		.mode = 0644,
> +		.proc_handler = &proc_dointvec,
> +	},
>  	{ .ctl_name = 0 }
>  };
> 
> @@ -215,7 +230,7 @@ static ctl_table sys_table[] = {
>  	  .ctl_name = CTL_KERN,
>  	  .procname = "kernel",
>  	  .mode = 0555,
> -	  .child = kdump_on_init_table,
> +	  .child = kdump_ctl_table,
>  	},
>  	{ .ctl_name = 0 }
>  };
> Index: GIT-torvalds/arch/ia64/kernel/mca.c
> =================================> --- GIT-torvalds.orig/arch/ia64/kernel/mca.c
> +++ GIT-torvalds/arch/ia64/kernel/mca.c
> @@ -1266,16 +1266,12 @@ ia64_mca_handler(struct pt_regs *regs, s
>  	} else {
>  		/* Dump buffered message to console */
>  		ia64_mlogbuf_finish(1);
> -#ifdef CONFIG_KEXEC
> -		atomic_set(&kdump_in_progress, 1);
> -		monarch_cpu = -1;
> -#endif
>  	}
> +
>  	if (notify_die(DIE_MCA_MONARCH_LEAVE, "MCA", regs, (long)&nd, 0, recover)
>  			= NOTIFY_STOP)
>  		ia64_mca_spin(__func__);
> 
> -
>  	if (atomic_dec_return(&mca_count) > 0) {
>  		int i;
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

