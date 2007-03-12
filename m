From: Jay Lan <jlan@sgi.com>
Date: Mon, 12 Mar 2007 20:35:10 +0000
Subject: Re: [Patch] min_low_pfn and max_low_pfn calcultion fix
Message-Id: <45F5B97E.2020607@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1172619535.20006.334.camel@linux-znh>
In-Reply-To: <1172619535.20006.334.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Magnus Damm wrote:
> On 28 Feb 2007 07:38:55 +0800, Zou Nan hai <nanhai.zou@intel.com> wrote:
>>
[excessive text deleted]

>>   So it is better to fix and clean up those issues.
>> Calculate min_low_pfn and max_low_pfn in a consistent way.
>>
>> Below is the patch, please review and comments
>>
>> Signed-off-by:  Zou Nan hai <nanhai.zou@intel.com>
> 
> I've seen similar problems on a HP rx2620 box using 2.6.20. I managed
> to resolve that problem with a patch similar to this one, but then I
> realized that the issue I was seeing had been solved already by some
> mm-related patch by Bob Picco that got included in 2.6.21-rc1.

I tested on 2.6.21-rc3 with DEBUG_VM turned on. The vanilla 2.6.21-rc3
without Nan-hai's patch, panicked on bugcheck on free_initmem->free_page
as predicted. We still need this patch.

However, the zero-size vmcore problem is back on SN. But that is a
dfiffernet problem.

Regards,
 - jay


> 
> So, I suspect that 2.6.21-rc1 and rc2 should work just fine without this
> patch.
> 
> / magnus
> 
> PS. Any comments on the EFI_LOADER_DATA for ELF core header would be
> greatly appreciated, I think it is sort of related to this issue as
> well.
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


