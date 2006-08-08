From: Dean Nelson <dcn@sgi.com>
Date: Tue, 08 Aug 2006 19:14:47 +0000
Subject: Re: Silent data corruption caused by XPC V2.
Message-Id: <20060808191447.GB30496@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060807174933.GB24663@lnx-holt.americas.sgi.com>
In-Reply-To: <20060807174933.GB24663@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Aug 08, 2006 at 11:52:41AM -0700, Yu, Fenghua wrote:
> 
> Seems the following part is missed in your patch:
> 
> --- arch/ia64/sn/kernel/xpc_main.c      2006-02-13 12:35:03.000000000
> -0800
> +++ arch/ia64/sn/kernel/xpc_main.c.new   2006-08-08 11:47:03.000000000
> -0700
> @@ -1374,6 +1374,7 @@ xpc_init(void)
>                 complete(&xpc_discovery_exited);
> 
>                 xpc_do_exit(xpcUnloading);
> +               kfree(xpc_remote_copy_buffer_base);
>                 return -EBUSY;
>         }


Actually, the very last line of xpc_do_exit() is the following:

        kfree(xpc_remote_copy_buffer_base);
}

I realize it's perhaps not the most straight-forward arrangement, but it
does have something to do with the various avenues through which our exit
processing can get invoked (not just by rmmod's call to xpc_exit()). 

I really do appreciate your feedback. Thanks.

Dean

