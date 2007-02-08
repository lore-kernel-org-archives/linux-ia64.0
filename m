From: Zou Nan hai <nanhai.zou@intel.com>
Date: Thu, 08 Feb 2007 05:11:49 +0000
Subject: Re: [RFC Patch]Use ar.kr2 for smp_processor_id
Message-Id: <1170911509.3230.27.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
References: <1170905324.3230.7.camel@linux-znh>
In-Reply-To: <1170905324.3230.7.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2007-02-08 at 14:55, Keith Owens wrote:
> Keith Owens (on Thu, 08 Feb 2007 17:37:54 +1100) wrote:
> >Zou Nan hai (on 08 Feb 2007 12:27:31 +0800) wrote:
> >>On Thu, 2007-02-08 at 14:04, Keith Owens wrote:
> >>> Zou Nan hai (on 08 Feb 2007 11:28:44 +0800) wrote:
> >>> >Pin ar.kr2 of each CPU, so that smp_processor_id can use it.
> >>> 
> >>> Historically ar.k2 has been reserved for debugging purposes, for
> >>> example in ivt.S.  Debuggers often need a location that can be
> used to
> >>> track progress, it has to be somewhere that does not rely on TLB
> >>> entries and is guaranteed to appear in MCA/INIT records - ar.k2 is
> >>> perfect for this.
> >>> 
> >>  Ok, seems that current kr3 is only used by ia64_itc_printk_clock?
> >>> Use Tony's suggestion of testing for a change in ar.k3 (guaranteed
> to
> >>> be unique on every cpu) and caching the corresponding cpu number
> when
> >>> it changes.
> >>> 
> >>  But why do we even need to cache it? 
> >>
> >>  It is already in a register if we put it to kr3. 
> >>  so smp_processor_id() could be very fast. and later sys_getcpu can
> >>also be very fast.
> >
> >ar.k3 is currently used for the address of the per-cpu data area,
> which
> >speeds up access to all the per-cpu data.  Changing ar.k3 to hold the
> >cpu number means an extra array calculation and lookup for every
> >per-cpu variable, slowing down the rest of the system.
> 
> Correction: ar.k3 contains the physical address of the per-cpu data
> area, virtual access to per-cpu data goes via the cpu local TLB and
> does not rely on an ar.k<n> variable.  ar.k3 is used in the MCA
> assembler handler, see GET_THIS_PADDR in include/asm-ia64/mca_asm.h
> and
> arch/ia64/kernel/mca_asm.S.
> 

 Since MCA is slow path, 
 so I think put smp_processor_id in ar.kr3 is a gain.

 We could even optimize get_cpu_var based on this...

 Thanks
 Zou Nan hai
