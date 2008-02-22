From: Russ Anderson <rja@sgi.com>
Date: Fri, 22 Feb 2008 23:44:31 +0000
Subject: Re: ia64_mca_cpe_int_handler
Message-Id: <20080222234428.GA29913@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <47BF02EC.4080102@bull.net>
In-Reply-To: <47BF02EC.4080102@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Feb 22, 2008 at 02:32:11PM -0800, Luck, Tony wrote:
> 
> The SAL spec doesn't say that we must have interrupts enabled if
> it is safe to do so, it says: "The operating system-corrected
> error handler shall run with interrupts enabled".

The footnote explains: "It is required that the operating system
handlers operate with interrupts enabled, so that system firmware
can manage its resources (like NVRAM based error records) without
impacting system performance."

The goal of limiting the performance impact of corrected errors
is certainly reasonable.  The system should not hold off other 
interrupts while handling corrected errors.  The trouble is if
we get a second corrected error while handling the first. 

What the polling mode code does is disable just the CPE interrupt.

	disable_irq_nosync(local_vector_to_irq(IA64_CPE_VECTOR));

Would it be unreasonable to disable the CPE interrupt, then enable
do the local_irq_enable() ?  It would functionally be the same as
going into polling mode for the length of time it takes to handle
the CPE, then returning to interrupt mode.  I think that would
meet both the letter and the intent of the SAL spec.



> Perhaps just update the comment to:
> 
> 		/* SAL spec says CMC and CPE handler must enable interrupts */
> 
> which at least points the reader a little more clearly to what is
> going on.  Either that or make the test:
> 
> 	if (sal_info_type = SAL_INFO_TYPE_CMC || sal_info_type = SAL_INFO_TYPE_CPE) {
> 		/* SAL spec states these should run w/ interrupts enabled */
> 
> [This looks way too verbose]
> 
> -Tony

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
