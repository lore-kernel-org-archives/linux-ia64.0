From: "Mallick, Asit K" <asit.k.mallick@intel.com>
Date: Wed, 17 Apr 2002 20:35:13 +0000
Subject: RE: [Linux-ia64] Patch to fix lfetches accessing beyond a page (c
Message-Id: <marc-linux-ia64-105590701905477@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905475@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905475@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David,

I agree that the real problem is the use of large page size mappings for the
kernel than the the normal page size. Special casing the <64MB will take
care of the memory hole below 1MB and hopefully DIG will specify the minimum
granularity for the physical memory layout that will not have holes. I agree
that we should fix this problem permanently.

But I also think that the code should not access memory beyond the page even
though it does not affect the functionality as these are hints. These
accesses can also cause performance problems.

Thanks,
Asit

> -----Original Message-----
> From: David Mosberger [mailto:davidm@napali.hpl.hp.com]
> Sent: Wednesday, April 17, 2002 12:35 PM
> To: Mallick, Asit K
> Cc: linux-ia64@linuxia64.org
> Subject: Re: [Linux-ia64] Patch to fix lfetches accessing 
> beyond a page
> (copy_page/clear_pa ge)
> 
> 
> >>>>> On Wed, 17 Apr 2002 11:51:15 -0700, "Mallick, Asit K" 
> <asit.k.mallick@intel.com> said:
> 
>   Asit> Here is a patch fix the lfetches accessing beyond a page that
>   Asit> can have a side effect of generating an MCA if the physical
>   Asit> memory does not exist. For example, copy_page will try to
>   Asit> access video memory for the page that ends at 640K and this
>   Asit> can cause MCA for some platforms. Some of the Bigsur UP boot
>   Asit> failures were root caused to this problem.
> 
>   Asit> Both copy page and clear_page are very performance critical
>   Asit> functions and tuned for both Itanium and McKinley. The patch
>   Asit> is implemented using unused slots (nops) and has no
>   Asit> performance impact.
> 
>   Asit> For kernels 2.4.18 and higher you will just need the patch for
>   Asit> copy_page().  clear_page and McKinley optimized copy_page has
>   Asit> been already taken care.
> 
> This patch only papers over the real problem, which is that there
> shouldn't be a WB translation covering anything other than normal
> memory in the first place.  I don't want to apply hack upon hack, just
> so it works for another while.  Let's fix this one permanently.  I
> think we may just have to bite the bullet and treat the <64MB
> specially in the alternate TLB handlers.  If we use a 4KB page size
> for that area, we should be good (assuming DIG goes ahead and does
> something sane about requiring a minimum granularity for physical
> memory).
> 
> 	--david
> 

