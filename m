From: Stephane Eranian <eranian@hpl.hp.com>
Date: Thu, 18 Nov 2004 23:46:13 +0000
Subject: Re: [PATCH] 2.6.10-rc1 pfmon broken by bad merge?
Message-Id: <20041118234613.GB23624@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041118230118.GC15892@esmail.cup.hp.com>
In-Reply-To: <20041118230118.GC15892@esmail.cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,
Please apply, there was a stray closing comment in my file, I think.

Thanks Grant.

On Thu, Nov 18, 2004 at 03:01:18PM -0800, Grant Grundler wrote:
> Tony,
> 
> Just pulled/rebuilt from the bk linux-ia64-release-2.6.10 tree
> and it failed to build with :
> arch/ia64/kernel/perfmon.c: In function `pfm_handle_work':
> arch/ia64/kernel/perfmon.c:5068: error: parse error before '/' token
> 
> Following trivial patch fixes what looks like a merge bug.
> 
> Signed-off-by: Grant Grundler <iod00d@hp.com>
> 
> grant
> 
> === arch/ia64/kernel/perfmon.c 1.100 vs edited ==> --- 1.100/arch/ia64/kernel/perfmon.c	2004-11-18 10:43:37 -08:00
> +++ edited/arch/ia64/kernel/perfmon.c	2004-11-18 14:58:03 -08:00
> @@ -5065,7 +5065,7 @@
>  	  * when returning to user level (PUStk=1), in which case
>  	  * there is no risk of kernel stack overflow due to deep
>  	  * interrupt nesting.
> -	  */                                                                         */
> +	  */
>  	BUG_ON(flags & IA64_PSR_I);
>  	local_irq_enable();
>  
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 

-Stephane
