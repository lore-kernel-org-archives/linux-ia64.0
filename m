From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 29 Jul 2003 23:26:42 +0000
Subject: Re: [patch] 2.4.21-ia64-030702 arch/ia64/kernel/unwind.c
Message-Id: <marc-linux-ia64-105952134021957@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105909779318784@msgid-missing>
In-Reply-To: <marc-linux-ia64-105909779318784@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 24 July 2003 2:59 am, Keith Owens wrote:
> On Sun, 20 Jul 2003 19:51:06 +1000, 
> Keith Owens <kaos@sgi.com> wrote:
> >This has been fixed once but must have slipped through the cracks.  It
> >only shows up when you turn on unwind debugging.
> 
> And another one, again it only shows up with unwind debugging.
> 
> --- linux/arch/ia64/kernel/unwind.c	2003-07-03 12:03:40.000000000 +1000
> +++ linux/arch/ia64/kernel/unwind.c	2003-07-24 16:45:34.000000000 +1000
> @@ -1955,7 +1955,7 @@
>  		   "  bsp    0x%lx\n"
>  		   "  sof    0x%lx\n"
>  		   "  ip     0x%lx\n",
> -		   info->bsp, sof, info->ip);
> +		   __FUNCTION__, info->bsp, sof, info->ip);
>  	find_save_locs(info);
>  }
>  
> @@ -1973,7 +1973,7 @@
>  		   "  bsp    0x%lx\n"
>  		   "  sol    0x%lx\n"
>  		   "  ip     0x%lx\n",
> -		   info->bsp, sol, info->ip);
> +		   __FUNCTION__, info->bsp, sol, info->ip);
>  	find_save_locs(info);
>  }

I applied this one, too.  And I'll push the changes to bkbits and kernel.org
in a minute.

Bjorn

