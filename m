From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Mon, 06 Dec 2004 12:42:42 +0000
Subject: Re: [RFC] I/O error handling for userspace
Message-Id: <41B453C2.5050203@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200412030831.25662.jbarnes@engr.sgi.com>
In-Reply-To: <200412030831.25662.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jesse Barnes wrote:
> On Friday, December 3, 2004 8:31 am, Jesse Barnes wrote:
> 
>>This patch adds support for sending a SIGBUS to a userspace application
>>using /proc/bus/pci to drive a device if an I/O error occurs.  We're using
>>this in house for the X server's BIOS emulator and it seems to be working
>>well.
>>
>>The idea is to track mmaped /proc/bus/pci regions so that the machine check
>>handler is able to properly determine which process is responsible for any
>>faults that occur (ia64 is interesting in that the error may not occur in
>>the process context that actually generated the bad reference).  If a match
>>is found, a SIGBUS is sent to the process, along with the address that
>>caused the fault.  The machine check record is then cleared and recovery
>>takes place (the assumption is that the signal to userspace is a sufficient
>>record of the error).

Cool!
BTW I have some short comments.

> ------------------------------------------------------------------------
> 
> === arch/ia64/kernel/mca.c 1.71 vs edited ==> --- 1.71/arch/ia64/kernel/mca.c	2004-11-11 10:04:30 -08:00
> +++ edited/arch/ia64/kernel/mca.c	2004-12-02 14:30:33 -08:00
> @@ -871,21 +873,69 @@
>  void
>  ia64_mca_ucmc_handler(void)
>  {
> +	struct io_range *range, *tmp;
> +	unsigned long io_addr = 0;
>  	pal_processor_state_info_t *psp = (pal_processor_state_info_t *)
>  		&ia64_sal_to_os_handoff_state.proc_state_param;
> -	int recover; 
> +	int recover = 0;
> +	ia64_err_rec_t *curr_record;
>  
>  	/* Get the MCA error record and log it */
>  	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_MCA);
>  
> -	/* TLB error is only exist in this SAL error record */
> -	recover = (psp->tc && !(psp->cc || psp->bc || psp->rc || psp->uc))
> -	/* other error recovery */
> -	   || (ia64_mca_ucmc_extension 
> -		&& ia64_mca_ucmc_extension(
> -			IA64_LOG_CURR_BUFFER(SAL_INFO_TYPE_MCA),
> -			&ia64_sal_to_os_handoff_state,
> -			&ia64_os_to_sal_handoff_state)); 

Where the ia64_mca_ucmc_extension had go? ... vanished? :-(


> + 	/* TLB errors are fixed up before we get here, so recover */
> + 	if (psp->tc) {
> + 		recover = 1;
> + 		goto return_to_sal;
> + 	}
> +

I'm not sure because I hadn't get any logs on crazy error situation, but
isn't it possible that an error log have both of tc and another(cc|bc|rc|uc)?
Why we could omit "!(psp->cc || psp->bc || psp->rc || psp->uc)" ?


> + 	/*
> + 	 * If it's not a bus check with a valid target identifier,
> + 	 * we don't have a chance.
> + 	 */
> + 	if (!psp->bc) {
> + 		recover = 0;
> + 		goto return_to_sal;
> + 	}
> +
> + 	/*
> + 	 * If we can't get this lock, we can't safely look at the list,
> + 	 * so give up.
> + 	 */
> + 	if (!spin_trylock(&io_range_list_lock)) {
> + 		recover = 0;
> + 		goto return_to_sal;
> + 	}
> +
> + 	curr_record = IA64_LOG_CURR_BUFFER(SAL_INFO_TYPE_MCA);
> +	io_addr = curr_record->proc_err.info->target_identifier;
> +
> + 	/*
> + 	 * See if an I/O error occured in a previously registered range
> + 	 */
> + 	list_for_each_entry_safe(range, tmp, &pci_io_ranges, range_list) {
> + 		if (range->start <= io_addr && io_addr <= range->end) {
> + 			struct siginfo siginfo;
> + 			struct task_struct *owner = NULL;
> + 			recover = 1;
> + 			siginfo.si_signo = SIGBUS;
> + 			siginfo.si_code = BUS_ADRERR;
> + 			siginfo.si_addr  = (void *) io_addr;
> + 			owner = find_task_by_pid(range->owner);
> + 			if (owner)
> + 				force_sig_info(SIGBUS, &siginfo, owner);
> + 			else {
> + 				/*
> + 				 * need to free memory too, is that safe
> + 				 * here?
> + 				 */
> + 				list_del(&range->range_list);
> + 			}
> + 		}
> + 	}
> + 	spin_unlock(&io_range_list_lock);
> +
> + return_to_sal:

force_sig_info() takes spinlock in it... I think calling this isn't safe on MCA.


The rest part of the patch (for legacies) seems to be functionally-independent.
I don't have enough ideas for legacy-maps, but I guess you have done good work.


Thanks,
H.Seto

