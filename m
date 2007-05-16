From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Wed, 16 May 2007 00:43:18 +0000
Subject: Re: Fix section conflict of ia64_mlogbuf_finish
Message-Id: <464A53A6.2050509@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070515164202.GA19839@deprecation.cyrius.com>
In-Reply-To: <20070515164202.GA19839@deprecation.cyrius.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

 >> I suspect EXPORT is left over from the initial development/debug.

Yes, that's right.

The reason why the EXPORT was there is that I supposed a optional use
of ia64_mlogbuf_finish expecting that there would be some non-standard
mca recovery module, module relating kdump or something.
However such module is not there at the moment.

Thanks,
H.Seto

Martin Michlmayr wrote:
> * Russ Anderson <rja@sgi.com> [2007-05-15 13:32]:
>> I suspect EXPORT is left over from the initial development/debug.
>> Either change is fine with me.
> 
> OK, then let's use this one instead:
> 
> 
> Subject: Fix section conflict of ia64_mlogbuf_finish
> 
> Building with GCC 4.2, I get the following error:
> 
>   CC      arch/ia64/kernel/mca.o
> arch/ia64/kernel/mca.c:275: error: __ksymtab_ia64_mlogbuf_finish causes a
> section type conflict
> 
> This is because ia64_mlogbuf_finish is both declared static and exported.
> 
> Signed-off-by: Martin Michlmayr <tbm@cyrius.com>
> 
> --- a/arch/ia64/kernel/mca.c
> +++ b/arch/ia64/kernel/mca.c
> @@ -272,7 +272,6 @@ static void ia64_mlogbuf_finish(int wait)
>  
>  	mlogbuf_finished = 1;
>  }
> -EXPORT_SYMBOL(ia64_mlogbuf_finish);
>  
>  /*
>   * Print buffered messages from INIT context.
> 
