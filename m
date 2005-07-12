From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 12 Jul 2005 00:14:29 +0000
Subject: Re: [PATCH] enable to read region 5 from /dev/kmem
Message-Id: <42D30B65.2060806@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42C501CD.4010907@jp.fujitsu.com>
In-Reply-To: <42C501CD.4010907@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote:
>>This patch allows users to read region 5 from /dev/kmem and 
>>enhances range check of it.
> 
> 
> I'm uneasy about this change to drivers/char/mem.c.  Won't it stop
> those architectures that have memory at physical 0x0 from accessing
> it?

Sorry,  I sent wrong patch.
This !ptr check should be done in read_kmem and kmem doesn't have address 0x0.

Another way is
=
#define KMEM_ERR_PTR (void *)-1

if (ptr = KMEM_ERR_PTR)
	return -EFAULT
=
or no check.

By the way, can ia64's copy_to_user(from, buf, size) catch bad "from" ?

Regards,
-- Kamezawa

> 
>  		ptr = xlate_dev_mem_ptr(p);
> -
> +		if (!ptr)
> +			return -EFAULT
> 
> -Tony
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


