From: Robin Holt <holt@sgi.com>
Date: Tue, 11 Jan 2005 12:03:30 +0000
Subject: Re: [patch] Altix BTE error handling fix
Message-Id: <20050111120330.GA15925@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501102333.j0ANXJ4p068948@efs.americas.sgi.com>
In-Reply-To: <200501102333.j0ANXJ4p068948@efs.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Jan 10, 2005 at 05:33:19PM -0600, Russ Anderson wrote:
> This patch fixes off-node BTE error handling.
> 
> Signed-off-by: Russ Anderson <rja@sgi.com>
> 
> ------------------------------------------------------------------
> Index: 2.6.11/arch/ia64/sn/kernel/bte_error.c
> =================================> --- 2.6.11.orig/arch/ia64/sn/kernel/bte_error.c	2005-01-10 15:39:36.813394456 -0600
> +++ 2.6.11/arch/ia64/sn/kernel/bte_error.c	2005-01-10 16:06:53.244516756 -0600
> @@ -47,6 +47,7 @@
>  	ii_icrb0_d_u_t icrbd;	/* II CRB Register D */
>  	ii_ibcr_u_t ibcr;
>  	ii_icmr_u_t icmr;
> +	ii_ieclr_u_t ieclr;
>  
>  	BTE_PRINTK(("bte_error_handler(%p) - %d\n", err_nodepda,
>  		    smp_processor_id()));
> @@ -131,6 +132,14 @@
>  	imem.ii_imem_fld_s.i_b0_esd = imem.ii_imem_fld_s.i_b1_esd = 1;
>  	REMOTE_HUB_S(nasid, IIO_IMEM, imem.ii_imem_regval);
>  
> +	/* Clear BTE0/1 error bits */
> +	ieclr.ii_ieclr_regval = 0;
> +	if (err_nodepda->bte_if[0].bh_error != BTE_SUCCESS)
> +		ieclr.ii_ieclr_fld_s.i_e_bte_0 = 1;
> +	if (err_nodepda->bte_if[1].bh_error != BTE_SUCCESS)
> +		ieclr.ii_ieclr_fld_s.i_e_bte_1 = 1;
> +	REMOTE_HUB_S(nasid, IIO_IECLR, ieclr.ii_ieclr_regval);
> +

Hardware will clear those when you reintialize the state machines.

>  	/* Reinitialize both BTE state machines. */
>  	ibcr.ii_ibcr_regval = REMOTE_HUB_L(nasid, IIO_IBCR);
>  	ibcr.ii_ibcr_fld_s.i_soft_reset = 1;
> @@ -152,7 +161,7 @@
>  		err_nodepda->bte_if[i].cleanup_active = 0;
>  		BTE_PRINTK(("eh:%p:%d Unlocked %d\n", err_nodepda,
>  			    smp_processor_id(), i));
> -		spin_unlock(&pda->cpu_bte_if[i]->spinlock);
> +		spin_unlock(&err_nodepda->bte_if[i].spinlock);

I thought this went in months ago.  I guess I need to check on
where this change currently is.
