From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 28 Feb 2001 06:09:48 +0000
Subject: Re: Re: Re: [Linux-ia64] Re: Lockups on 2.4.1
Message-Id: <marc-linux-ia64-105590693005219@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005190@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005190@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

OK, this makes sense: our systems have ptc.g enabled, which explains
why we haven't seen this problem.  I made the change of using
smp_resend_flush_tlb() but also increased the timeout by a factor of
10.

Thanks,

	--david

>>>>> On Thu, 22 Feb 2001 14:48:03 -0600 (CST), Jack Steiner <steiner@sgi.com> said:

  >> > Anyway, I have ITPs connected to the IBM hardware and have
  >> noticed that > when the lockup occurs, and we lose video, at
  >> least one of the CPUs is > executing in flush_tlb_no_ptcg() or
  >> handle_IPI(), in the 'do' loop where > TLB > entries are being
  >> purged. What I have observed is that the end address and > the
  >> start address are in completely different regions. Usually, the
  >> start > address > is in region register 1 (address of
  >> 0x2000XXXXXXXXXXXX) and the end address > is in region register 3
  >> (address of 0x6000XXXXXXXXXXXX). I don't know if > this > is the
  >> same problem I am seeing on the Lion, but I plan to connect and
  >> ITP > and > a serial console (although we haven't been able to
  >> get one to work yet on > the > Lion with BIOS 71) to see if the
  >> symptoms are the same.
  >> 
  >> FWIW, we have seen EXACTLY the same hang running here on our
  >> system.  The start/end addresses for the purge cross region
  >> boundaries.
  >> 
  >> 
  >> We are running a 2.4.0 kernel.

  Jack> I found a problem that was causing the lockup described above
  Jack> & I suspect this may responsible for some of the other hangs
  Jack> various folks have seen.

  Jack> There is code in flush_tlb_no_ptcg() that resends the IPI if
  Jack> other cpus have not responded within a short time. If this
  Jack> code get invoked, then it is possible for flush_cpu_count to
  Jack> get corrupted. When that happens, a cpu can be executing in
  Jack> handle_IPI() while flush_start/flush_end are changing.  A cpu
  Jack> can pick up a non-matching flush_start/flush_end. This leads
  Jack> to hangs or lost TLB flushes.

  Jack> To verify that this could cause the hang, I changed the
  Jack> timeout in flush_tlb_no_ptcg() from 40000UL to 400UL. I hung
  Jack> before getting to multiuser mode with flush_start/flush_end in
  Jack> different regions.

  Jack> Here is the patch I used. Note: this is against 2.4.0,


  Jack> --- linux-trillian/arch/ia64/kernel/smp.c Thu Feb 22 14:35:28
  Jack> 2001 +++ linux/arch/ia64/kernel/smp.c Thu Feb 22 14:19:46 2001
  Jack> @@ -321,6 +321,16 @@ { send_IPI_allbutself(IPI_FLUSH_TLB); } +
  Jack> +void +smp_resend_flush_tlb(void) +{ + /* + * Really need a
  Jack> null IPI but since this rarely should happen & + * since this
  Jack> code will go away, lets not add one.  + */ +
  Jack> send_IPI_allbutself(IPI_RESCHEDULE); +} #endif /*
  Jack> !CONFIG_ITANIUM_PTCG */
 
  Jack>  /* --- linux-trillian/arch/ia64/mm/tlb.c Thu Feb 22 14:35:28
  Jack> 2001 +++ linux/arch/ia64/mm/tlb.c Thu Feb 22 14:19:50 2001 @@
  Jack> -59,6 +59,7 @@ flush_tlb_no_ptcg (unsigned long start,
  Jack> unsigned long end, unsigned long nbits) { extern void
  Jack> smp_send_flush_tlb (void); + extern void smp_resend_flush_tlb
  Jack> (void); unsigned long saved_tpr = 0; unsigned long flags;
 
  Jack> @@ -101,9 +102,8 @@ { unsigned long start = ia64_get_itc();
  Jack> while (atomic_read(&flush_cpu_count) > 0) { - if
  Jack> ((ia64_get_itc() - start) > 40000UL) { -
  Jack> atomic_set(&flush_cpu_count, smp_num_cpus - 1); -
  Jack> smp_send_flush_tlb(); + if ((ia64_get_itc() - start) > 400UL)
  Jack> { + smp_resend_flush_tlb(); start = ia64_get_itc(); } }

  Jack> -- Thanks

  Jack> Jack Steiner (651-683-5302) (vnet 233-5302) steiner@sgi.com


  Jack> _______________________________________________ Linux-IA64
  Jack> mailing list Linux-IA64@linuxia64.org
  Jack> http://lists.linuxia64.org/lists/listinfo/linux-ia64

