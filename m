From: Jay Lan <jlan@sgi.com>
Date: Wed, 14 Mar 2007 15:27:35 +0000
Subject: Re: [Patch] min_low_pfn and max_low_pfn calcultion fix
Message-Id: <45F81467.2010302@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1172619535.20006.334.camel@linux-znh>
In-Reply-To: <1172619535.20006.334.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Magnus Damm wrote:
[snip]
>>
>> I tested on 2.6.21-rc3 with DEBUG_VM turned on. The vanilla 2.6.21-rc3
>> without Nan-hai's patch, panicked on bugcheck on free_initmem->free_page
>> as predicted. We still need this patch.
> 
> Ok, thanks for testing. =)
> 
>> However, the zero-size vmcore problem is back on SN. But that is a
>> dfiffernet problem.
> 
> Argh, more problems...

I found the problem. It was the "elfcorehdr" introduced in 2.6.21-rc1.
Without specifying it, the elfcorehdr_addr is initialized to
ELFCORE_ADDR_MAX. Later, a check in reserve_elfcorehdr will fail:
        if (elfcorehdr_addr >= ELFCORE_ADDR_MAX)
                return -EINVAL;

Is it supposed to be a physical address to store elf core header?
If so, it is not possible for SN to provide a physical address at
boot time, just like in the case of crashkernel=X@Y where Y is not used.

Thanks,
 - jay


> 
> / magnus
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

