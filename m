From: Jay Lan <jlan@sgi.com>
Date: Tue, 13 Mar 2007 19:28:51 +0000
Subject: Re: [Patch] min_low_pfn and max_low_pfn calcultion fix
Message-Id: <45F6FB73.6010803@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1172619535.20006.334.camel@linux-znh>
In-Reply-To: <1172619535.20006.334.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote:
>> I tested on 2.6.21-rc3 with DEBUG_VM turned on. The vanilla 2.6.21-rc3
>> without Nan-hai's patch, panicked on bugcheck on free_initmem->free_page
>> as predicted. We still need this patch.
> 
> I've applied Nan hai's patch ... will push upstream in a little while.

Thanks!

> 
>> However, the zero-size vmcore problem is back on SN. But that is a
>> differnet problem.
> 
> I applied a fix that was supposed to fix this after -rc3.  It is
> in Linus' tree now.  Let me know if it really is still broken.

I git pull from Linus' tree yesterday afternoon, and i still have the
zero sized vmcore problem on SN. I will look into this.

Regards,
 - jay

> 
> -Tony
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

