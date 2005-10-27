From: Dean Roe <roe@sgi.com>
Date: Thu, 27 Oct 2005 18:31:04 +0000
Subject: Re: [ PATCH ] - Avoid slow TLB purges on SGI Altix systems
Message-Id: <20051027183104.GA12888@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F04C8CF40@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F04C8CF40@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Dean Roe <roe@sgi.com>, linux-ia64@vger.kernel.org, linux-mm@kvack.org

On Thu, Oct 27, 2005 at 09:01:53AM -0700, Luck, Tony wrote:
> -	if (mm != current->active_mm) {
> -		/* this does happen, but perhaps it's not worth optimizing for? */
> -#ifdef CONFIG_SMP
> -		flush_tlb_all();
> -#else
> -		mm->context = 0;
> -#endif
> -		return;
> -	}
> 
> Your patch moves this secion of code up to ia64_global_tlb_purge(),
> but the new code that is added there doesn't include the UP case
> where mm->context is set to zero.
> 
> -Tony
> 

flush_tlb_range() only calls platform_global_tlb_purge() for CONFIG_SMP,
so there's no point in having that code in ia64_global_tlb_purge().

Dean

-- 
Dean Roe
Silicon Graphics, Inc.
roe@sgi.com
