From: Zou Nan hai <nanhai.zou@intel.com>
Date: Thu, 08 Feb 2007 04:27:31 +0000
Subject: Re: [RFC Patch]Use ar.kr2 for smp_processor_id
Message-Id: <1170908851.3230.18.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
References: <1170905324.3230.7.camel@linux-znh>
In-Reply-To: <1170905324.3230.7.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2007-02-08 at 14:04, Keith Owens wrote:
> Zou Nan hai (on 08 Feb 2007 11:28:44 +0800) wrote:
> >Pin ar.kr2 of each CPU, so that smp_processor_id can use it.
> 
> Historically ar.k2 has been reserved for debugging purposes, for
> example in ivt.S.  Debuggers often need a location that can be used to
> track progress, it has to be somewhere that does not rely on TLB
> entries and is guaranteed to appear in MCA/INIT records - ar.k2 is
> perfect for this.
> 
  Ok, seems that current kr3 is only used by ia64_itc_printk_clock?
> Use Tony's suggestion of testing for a change in ar.k3 (guaranteed to
> be unique on every cpu) and caching the corresponding cpu number when
> it changes.
> 
  But why do we even need to cache it? 

  It is already in a register if we put it to kr3. 
  so smp_processor_id() could be very fast. and later sys_getcpu can
also be very fast.
 

  Thanks
  Zou Nan hai
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64"
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
