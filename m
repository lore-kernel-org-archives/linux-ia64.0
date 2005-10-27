From: Dean Roe <roe@sgi.com>
Date: Thu, 27 Oct 2005 18:44:29 +0000
Subject: Re: [ PATCH ] - Avoid slow TLB purges on SGI Altix systems
Message-Id: <20051027184429.GA13190@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F04CC08DF@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F04CC08DF@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Dean Roe <roe@sgi.com>, linux-ia64@vger.kernel.org, linux-mm@kvack.org

On Thu, Oct 27, 2005 at 11:41:13AM -0700, Luck, Tony wrote:
> >flush_tlb_range() only calls platform_global_tlb_purge() for CONFIG_SMP,
> >so there's no point in having that code in ia64_global_tlb_purge().
> 
> So you have dropped the "mm->context = 0;" for the UP case (and replaced
> it with a series of ia64_ptcl() calls).
> 
> To maintain the old behaivour you need to have:
> 
> #ifndef SMP
> 	if (mm != current->active_mm) {
> 		mm->context = 0;
> 		return;
> 	}
> #endif
> 
> in the start of flush_tlb_range().
> 
> 
> -Tony
> 

Sorry, now I see.  Fixed patch coming soon.

Thanks,
Dean

-- 
Dean Roe
Silicon Graphics, Inc.
roe@sgi.com
(651) 683-5203
