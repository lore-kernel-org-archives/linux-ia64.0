From: Alex Williamson <alex.williamson@hp.com>
Date: Sat, 06 Dec 2003 15:23:50 +0000
Subject: Re: Deadlock in ia64_mca_cmc_int_caller
Message-Id: <marc-linux-ia64-107072425128279@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107068420607204@msgid-missing>
In-Reply-To: <marc-linux-ia64-107068420607204@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith,

   We debugged a similar problem with the old CMC/CPE code recently. 
However, the latest version in 2.4/2.6 fixed that problem.  So are you
actually hitting a deadlock when ia64_mca_cmc_int_caller() calls
smp_call_function(ia64_mca_cmc_vector_enable, NULL, 1, 0)?  I've reached
the same conclusion about smp_call_function, my mistake for using it in
the first place, it's way too dangerous.  We need to enable/disable the
CMC vector in a better context or use another mechanism.

	Alex

On Fri, 2003-12-05 at 21:16, Keith Owens wrote:
> ia64_mca_cmc_int_caller() calls smp_call_function() which waits until
> all cpus have taken the IPI before returning.  This interacts badly
> with locks that are sometimes taken with interrupts disabled and
> sometimes with interrupts enabled, smp_call_function can deadlock.
> 
> cpu 3                                                   cpu 0
> Holds tasklist_lock with interrupts enabled,
> it did read_lock() or write_lock().
> 
>                                                 Does read_lock_irq() or
>                                                 write_lock_irq().  Spinning
>                                                 disabled waiting for tasklist_lock.
> 
> CMC interrupt occurs
> 
> ia64_mca_cmc_int_caller() calls smp_call_function()
> 
> smp_call_function() sends IPI to other cpus
> 
>                                                 IPI on cpu 0 blocked, it is disabled
> 						waiting for tasklist_lock.
> 
> smp_call_function() waits until IPI reaches
> all other cpus.
> 
> cpu 0 never responds, we never release the
> tasklist lock, deadlock.
> 
> AFAICT it is never safe to call smp_call_function() from an interrupt
> handler.
> 
> The unsafe nature of smp_call_function is not ia64 specific.  ix86 can
> deadlock this way if any ix86 code calls smp_call_function from an
> interrupt handler.
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

