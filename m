From: "Mallick, Asit K" <asit.k.mallick@intel.com>
Date: Wed, 28 Feb 2001 00:39:57 +0000
Subject: RE: Re: Re: [Linux-ia64] Re: Lockups on 2.4.1
Message-Id: <marc-linux-ia64-105590693005218@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005190@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005190@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jack,

Thanks for investigating the problem and the patch. The problem is happening
because the timeout (40000UL) is not long enough. The processor is taking
long time than this to complete the handle_IPI and processor doing the
flush_tlb_no_ptcg is timing out and sending the IPI again. So, we should
increase the timeout rather than decreasing the timeout to avoid extra
reschedule IPIs.

Thanks,
Asit


> -----Original Message-----
> From: Jack Steiner [mailto:steiner@sgi.com]
> Sent: Thursday, February 22, 2001 12:48 PM
> To: linux-ia64@linuxia64.org
> Subject: Re: Re: Re: [Linux-ia64] Re: Lockups on 2.4.1
> 
> 
> 
> > > Anyway, I have ITPs connected to the IBM hardware and 
> have noticed that
> > > when the lockup occurs, and we lose video, at least one 
> of the CPUs is
> > > executing in flush_tlb_no_ptcg() or handle_IPI(), in the 
> 'do' loop where
> > > TLB
> > > entries are being purged. What I have observed is that 
> the end address and
> > > the start address are in completely different regions. 
> Usually, the start
> > > address
> > > is in region register 1 (address of 0x2000XXXXXXXXXXXX) 
> and the end address
> > > is in region register 3 (address of 0x6000XXXXXXXXXXXX). 
> I don't know if
> > > this
> > > is the same problem I am seeing on the Lion, but I plan 
> to connect and ITP
> > > and
> > > a serial console (although we haven't been able to get 
> one to work yet on
> > > the
> > > Lion with BIOS 71) to see if the symptoms are the same.
> > 
> > FWIW, we have seen EXACTLY the same hang running here on our system.
> > The start/end addresses for the purge cross region boundaries.
> > 
> > 
> > We are running a 2.4.0 kernel.
> 
> I found a problem that was causing the lockup described above 
> & I suspect this
> may responsible for some of the other hangs various folks have seen.
> 
> There is code in flush_tlb_no_ptcg() that resends the IPI if other
> cpus have not responded within a short time. If this code get 
> invoked, then
> it is possible for flush_cpu_count to get corrupted. When 
> that happens, a cpu
> can be executing in handle_IPI() while flush_start/flush_end 
> are changing.
> A cpu can pick up a non-matching flush_start/flush_end. This 
> leads to  hangs or
> lost TLB flushes.
> 
> To verify that this could cause the hang, I changed the timeout in
> flush_tlb_no_ptcg() from 40000UL to 400UL. I hung before 
> getting to multiuser mode
> with flush_start/flush_end in different regions.
> 
> Here is the patch I used. Note: this is against 2.4.0,
> 
> 
> --- linux-trillian/arch/ia64/kernel/smp.c	Thu Feb 22 14:35:28 2001
> +++ linux/arch/ia64/kernel/smp.c	Thu Feb 22 14:19:46 2001
> @@ -321,6 +321,16 @@
>  {
>  	send_IPI_allbutself(IPI_FLUSH_TLB);
>  }
> +
> +void
> +smp_resend_flush_tlb(void)
> +{
> +	/*
> +	 * Really need a null IPI but since this rarely should happen &
> +	 * since this code will go away, lets not add one.
> +	 */
> +	send_IPI_allbutself(IPI_RESCHEDULE);
> +}
>  #endif	/* !CONFIG_ITANIUM_PTCG */
>  
>  /*
> --- linux-trillian/arch/ia64/mm/tlb.c	Thu Feb 22 14:35:28 2001
> +++ linux/arch/ia64/mm/tlb.c	Thu Feb 22 14:19:50 2001
> @@ -59,6 +59,7 @@
>  flush_tlb_no_ptcg (unsigned long start, unsigned long end, 
> unsigned long nbits)
>  {
>  	extern void smp_send_flush_tlb (void);
> +	extern void smp_resend_flush_tlb (void);
>  	unsigned long saved_tpr = 0;
>  	unsigned long flags;
>  
> @@ -101,9 +102,8 @@
>  	{
>  		unsigned long start = ia64_get_itc();
>  		while (atomic_read(&flush_cpu_count) > 0) {
> -			if ((ia64_get_itc() - start) > 40000UL) {
> -				atomic_set(&flush_cpu_count, 
> smp_num_cpus - 1);
> -				smp_send_flush_tlb();
> +			if ((ia64_get_itc() - start) > 400UL) {
> +				smp_resend_flush_tlb();
>  				start = ia64_get_itc();
>  			}
>  		}
> 
> -- 
> Thanks
> 
> Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 

