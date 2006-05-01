From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Mon, 01 May 2006 07:20:55 +0000
Subject: Re: [PATCH] ia64: avoid broken SAL_CACHE_FLUSH implementations
Message-Id: <20060501072055.GD9178@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="fOHHtNG4YXGJ0yqR"
List-Id: <linux-ia64.vger.kernel.org>
References: <200601301511.57109.bjorn.helgaas@hp.com>
In-Reply-To: <200601301511.57109.bjorn.helgaas@hp.com>
To: linux-ia64@vger.kernel.org


--fOHHtNG4YXGJ0yqR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jan 30, 2006 at 03:11:57PM -0700, Bjorn Helgaas wrote:
> +static void __init
> +check_sal_cache_flush (void)
> +{
> +	/*
> +	 * Schedule a timer interrupt, wait until it's reported, and see if
> +	 * SAL_CACHE_FLUSH drops it.
> +	 */
> +	itv = ia64_get_itv();
> +	BUG_ON((itv & (1 << 16)) == 0);
> +
> +	ia64_set_itv(IA64_TIMER_VECTOR);
... [stuff] ...
> +	ia64_set_itv(itv);

Sorry I didn't notice earlier, but that BUG_ON triggers for me on the
simulator.  AFAICS the mask for itv is set in cpu_init(), which comes
after sal_init().  Consequently on the simulator the itv still has its
start value of zero.  I've probably missed something, but I wonder why
at this stage of the boot you even need to save and restore the itv?

-i

Signed-Off-By: Ian Wienand <ianw@gelato.unsw.edu.au>

--- linux-2.6.17-rc3-lvhpt/arch/ia64/kernel/sal.c	2006-03-20 16:53:29.000000000 +1100
+++ linux-2.6.17-rc3/arch/ia64/kernel/sal.c	2006-05-01 17:20:11.000000000 +1000
@@ -227,7 +227,7 @@
 static void __init
 check_sal_cache_flush (void)
 {
-	unsigned long flags, itv;
+	unsigned long flags;
 	int cpu;
 	u64 vector;
 
@@ -238,9 +238,6 @@
 	 * Schedule a timer interrupt, wait until it's reported, and see if
 	 * SAL_CACHE_FLUSH drops it.
 	 */
-	itv = ia64_get_itv();
-	BUG_ON((itv & (1 << 16)) == 0);
-
 	ia64_set_itv(IA64_TIMER_VECTOR);
 	ia64_set_itm(ia64_get_itc() + 1000);
 
@@ -260,7 +257,6 @@
 		ia64_eoi();
 	}
 
-	ia64_set_itv(itv);
 	local_irq_restore(flags);
 	put_cpu();
 }




--fOHHtNG4YXGJ0yqR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD8DBQFEVbbXWDlSU/gp6ecRAm1yAJ9+Mo231kwVA4gQpZTUWouI93cgmwCeLdSA
iWK8ie0VLNLonto9Khc7L+M=
=iDl1
-----END PGP SIGNATURE-----

--fOHHtNG4YXGJ0yqR--
