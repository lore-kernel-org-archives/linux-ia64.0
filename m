From: Russ Anderson <rja@sgi.com>
Date: Wed, 27 Feb 2008 23:04:44 +0000
Subject: Re: ia64_mca_cpe_int_handler - take 2
Message-Id: <20080227230444.GA22656@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <47C530E6.7080905@bull.net>
In-Reply-To: <47C530E6.7080905@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Feb 27, 2008 at 10:44:06AM +0100, Zoltan Menyhart wrote:
>  	/* Get the CPE error record and log it */
> -	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CPE);
> -
> +	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CPE,
> +					1 /* not called from the MCA/INIT handlers */);

Minor nit.  Please #define values.

#define MCA_IRQ_NOTSAFE	0	/* called from the MCA/INIT handlers */
#define MCA_IRQ_SAFE	1	/* not called from the MCA/INIT handlers */

	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CPE, MCA_IRQ_SAFE);


Thanks,
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
