From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 08 Aug 2003 17:15:30 +0000
Subject: Re: [patch] 2.4.21-ia64-030702 arch/ia64/kernel/mca.c
Message-Id: <marc-linux-ia64-106036294510656@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105909779318784@msgid-missing>
In-Reply-To: <marc-linux-ia64-105909779318784@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 07 August 2003 6:41 pm, Keith Owens wrote:
> On Thu, 7 Aug 2003 17:03:22 -0600, 
> Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:
> >I don't see any conversion -- just the addition of several ia64_platform_is()
> >checks which I object to, especially when they change the behavior of
> >things that are not obviously platform-dependent.  For example, I think
> >we should come up with a strategy for breaking SAL locks and clearing INIT
> >logs that everybody can agree on.  Error handling is confusing enough
> >without making it platform-dependent.
> 
> I agree, but so far only SN has any requirements for special processing
> in mca.c.  Without a second platform, it is not clear what the coding
> model should be.  I suggest you put in the sn2 changes and we review
> them when another platform has similar requirements.

I don't understand the changes well enough to be convinced that
they're SGI-specific.  For instance:

> +#ifdef CONFIG_SMP
> +	if (ia64_platform_is("sn2") && sal_lock.lock) {
> +		udelay(500000);
> +		sal_lock.lock = 0;
> +	}
> +#endif

ia64_sal_get_state_info() uses SAL_CALL(), which acquires sal_lock.
So it seems that every platform would deadlock if we MCA in the
middle of a previous SAL call.  Or is there something peculiar about
SGI firmware?

> +	if (ia64_platform_is("sn2")) {
> +		/* SN saves logs until next boot */
> +		;
> +	} else {
> +		/* Clear the INIT SAL logs now that they have been saved in the OS buffer */
> +		ia64_sal_clear_state_info(SAL_INFO_TYPE_INIT);
> +	}

You added back ia64_sal_clear_state_info() for all non-SGI platforms,
which I don't think we want.

> @@ -2076,6 +2141,11 @@ ia64_log_proc_dev_err_info_print (sal_lo
> +		if (ia64_platform_is("sn2")) {
> +			platform_plat_specific_err_print((int)slpi->header.len,
> +			      0, (void*)slpi, prfunc);
> +			return;
> +		}

> @@ -2301,7 +2371,13 @@ ia64_log_print(int sal_info_type, prfunc
> -		prfunc("+MCA INIT ERROR LOG (UNIMPLEMENTED)\n");
> +		if (ia64_platform_is("sn2")) {
> +			prfunc("+BEGIN HARDWARE ERROR STATE AT INIT\n");
> +			platform_err = ia64_log_platform_info_print(IA64_LOG_CURR_BUFFER(sal_info_type), prfunc);
> +			prfunc("+END HARDWARE ERROR STATE AT INIT\n");
> +		} else {
> +			prfunc("+MCA INIT ERROR LOG (UNIMPLEMENTED)\n");
> +		}

Is there any reason not to do these on all platforms?  The
"platform_plat_specific_err_print" looks a lot like a platform vector
anyway, so I don't see the point of another test.

Bjorn


