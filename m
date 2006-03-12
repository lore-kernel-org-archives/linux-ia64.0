From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Sun, 12 Mar 2006 15:53:13 +0000
Subject: RE: [patch] mark init related functions/variable with __init declaration
Message-Id: <200603121553.k2CFrBg09468@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200603120111.k2C1BNg23144@unix-os.sc.intel.com>
In-Reply-To: <200603120111.k2C1BNg23144@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Chen, Kenneth W wrote on Saturday, March 11, 2006 5:11 PM
> Speaking of the devil, bunch of functions and variable in mca.c
> can be marked with __init variants.
> 
> -void
> +void __devinit
>  ia64_mca_cmc_vector_setup (void)

Note to self: __cpuinit is probably a better one to use.

