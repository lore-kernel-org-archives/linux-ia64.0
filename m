From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Sun, 09 Jan 2005 16:24:37 +0000
Subject: Re: [PATCH] ia64: reset console_loglevel so INIT output always goes to
Message-Id: <200501091624.j09GObm6046175@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1105140871.25267.50.camel@eeyore>
In-Reply-To: <1105140871.25267.50.camel@eeyore>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bjorn Helgaas wrote:
> 
> Reset console_loglevel early in INIT handler.  Otherwise, if
> it has been turned down (i.e., with "dmesg -n1"), the user may
> see no effect at all from issuing an INIT.  We're never going
> to run any more user code, so there won't be any opportunity for
> anything to collect the output from the dmesg buffer.

As Keith pointed out, we are working on returning from an INIT.

Would it be reasonable to save the current console_loglevel, 
set console_loglevel up to 15, call init_handler_platform(), and 
then set console_loglevel back to the original level?  

Right now init_handler_platform() never returns.  When the code
is improved to return, the console_loglevel will get restored
to the correct level.
 
> Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
> 
> === arch/ia64/kernel/mca.c 1.71 vs edited ==> --- 1.71/arch/ia64/kernel/mca.c	2004-11-11 11:04:30 -07:00
> +++ edited/arch/ia64/kernel/mca.c	2005-01-07 16:22:54 -07:00
> @@ -1133,6 +1133,7 @@
>  	pal_min_state_area_t *ms;
>  
>  	oops_in_progress = 1;	/* avoid deadlock in printk, but it makes recovery dodgy */
> +	console_loglevel = 15;	/* make sure printks make it to console */
>  
>  	printk(KERN_INFO "Entered OS INIT handler. PSP=%lx\n",
>  		ia64_sal_to_os_handoff_state.proc_state_param);


-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
