From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Fri, 16 Sep 2005 04:36:28 +0000
Subject: Re: [PATCH] mca_drv cleanup
Message-Id: <432A4BCC.2070802@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <432A38A9.509@jp.fujitsu.com>
In-Reply-To: <432A38A9.509@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Peter Chubb wrote:
> If you're going to tidy those up, how about changing the style to
> conform to Documentation/CodingStyle at the same time?
> 
>  	/* whether physical address is valid or not */ 
> - if ( !ia64_phys_addr_valid(paddr) ) 
> + if ( !ia64_phys_addr_valid(paddr) ) return ISOLATE_NG;
> 
> e.g., 
>   if (!ia64_phys_addr_valid(paddr))
> 	return ISOLATE_NG;

Thank you for pointing it out.
The attached new one has additional coding style fixes.

Thanks,
H.Seto


There were some trailing white spaces, long lines, brackets in
weird style etc.  This patch cleans them up.

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>

