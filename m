From: Russ Anderson <rja@sgi.com>
Date: Thu, 02 Nov 2006 13:07:25 +0000
Subject: Re: [patch] Update processor_info features
Message-Id: <200611021307.kA2D7PGE28958017@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200610262100.k9QL0Sf821995144@clink.americas.sgi.com>
In-Reply-To: <200610262100.k9QL0Sf821995144@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony Luck wrote:
> 
> Some speeling mistales ... 

Argh.  
 
> +	"Simple unimplimented instr addresses",
>                     ^
> 
> +	"Virtual machine features implemeted",
>                                        ^
> 
> ... but I can fix those up.

Thanks.

>                              Thanks for ploughing through
> the latest SDM.  Are these three patches all ... or are you
> working on more?

There is a new set of PAL virtualization support procedures.
I assume they will be needed.

#define PAL_VP_CREATE          265     /* Initialize a new VPD */
#define PAL_VP_ENV_INFO        266     /* Get params for new virtual environment */
#define PAL_VP_EXIT_ENV        267     /* Exit a virtual environment */
#define PAL_VP_INIT_ENV        268     /* Enter a virtual environment */
#define PAL_VP_REGISTER        269     /* Register a different host IVT */
#define PAL_VP_RESTORE         270     /* Restore virtual processor state on logical CPU */
#define PAL_VP_SAVE            271     /* Save virtual processor state on logical CPU */
#define PAL_VP_TERMINATE       272     /* Terminate operation for the specified virtual CPU */


-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
