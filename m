From: Robin Holt <holt@sgi.com>
Date: Tue, 10 May 2005 15:19:44 +0000
Subject: Re: [PATCH] - new macros for SGI SN simulator
Message-Id: <20050510151943.GA32438@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050510150045.GA6609@sgi.com>
In-Reply-To: <20050510150045.GA6609@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jack,

How about cleaning up all the whitespace problems in the nasid_slice_to_cpuid()
function.  There is a trailing tab following the long cpu; declaration.

Sorry for nit-picking,
Robin

> @@ -622,7 +633,7 @@ nasid_slice_to_cpuid(int nasid, int slic
>  {
>  	long cpu;
>  	
  ^^^^^^ Right there.
> -	for (cpu=0; cpu < NR_CPUS; cpu++) 
> +	for (cpu=0; cpu < NR_CPUS; cpu++)
>  		if (nodepda->phys_cpuid[cpu].nasid = nasid && nodepda->phys_cpuid[cpu].slice = slice)
>  			return cpu;

