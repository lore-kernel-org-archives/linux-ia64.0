From: Jesse Barnes <jbarnes@sgi.com>
Date: Thu, 14 Oct 2004 21:00:32 +0000
Subject: Re: Double spin_unlock in bte.c
Message-Id: <200410141600.33141.jbarnes@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041014114003.GF19122@lnx-holt.americas.sgi.com>
In-Reply-To: <20041014114003.GF19122@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony, I don't think there's any hurry on this one, so you can just send it 
along post-2.6.9 if you want.  Hopefully it won't conflict with Pat's big sn2 
patches.

Acked-by: Jesse Barnes <jbarnes@sgi.com>

On Thursday, October 14, 2004 6:40 am, Robin Holt wrote:
> If all bte interfaces are in use, the current code will leave the
> bte pointer set when exiting from the loop trying to locate an
> interface to use.  This results in two processes using the same
> interface and both trying to free the same one.  With a
> premptible kernel, this results in the preempt count getting
> off.
>
> Signed-off-by: Robin Holt
>
>
> Index: linux-2.6/arch/ia64/sn/kernel/bte.c
> =================================> --- linux-2.6.orig/arch/ia64/sn/kernel/bte.c 2004-10-06 11:48:25.000000000
> -0500 +++ linux-2.6/arch/ia64/sn/kernel/bte.c 2004-10-14 06:34:45.000000000
> -0500 @@ -131,12 +131,12 @@
>          (BTE_LNSTAT_LOAD(bte) & BTE_ACTIVE)) {
>       /* Got the lock but BTE still busy */
>       spin_unlock(&bte->spinlock);
> -     bte = NULL;
>      } else {
>       /* we got the lock and it's not busy */
>       break;
>      }
>     }
> +			bte = NULL;
>  		}
>
>  		if (bte != NULL) {
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
