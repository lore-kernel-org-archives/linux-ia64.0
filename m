From: Arun Sharma <arun.sharma@intel.com>
Date: Thu, 02 Oct 2003 01:30:00 +0000
Subject: Re: [PATCH] long format VHPT
Message-Id: <marc-linux-ia64-106505830403296@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106453902218848@msgid-missing>
In-Reply-To: <marc-linux-ia64-106453902218848@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Darren Williams wrote:
>  
> -#define ia64_rid(ctx,addr)	(((ctx) << 3) | (addr >> 61))
> +#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
> +#define redistribute_rid(rid)	(((rid) & ~0xffff) | (((rid) << 8) & 0xff00) | (((rid) >> 8) & 0xff))
> +#else
> +#define redistribute_rid(rid)	(rid)
> +#endif
> +#define ia64_rid(ctx,addr)	redistribute_rid(((ctx) << 3) | (addr >> 61))
>  

Hi Darren, Can you explain what this code is trying to do ?

	-Arun

