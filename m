From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 13 Oct 2006 18:54:22 +0000
Subject: Re: Patch [2/2] relax per-cpu TLB requirement to DTC
Message-Id: <Pine.LNX.4.64.0610131152200.26144@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <000201c6eeea$2b134940$ff0da8c0@amr.corp.intel.com>
In-Reply-To: <000201c6eeea$2b134940$ff0da8c0@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 13 Oct 2006, Chen, Kenneth W wrote:

> -	andcm r18=0x10,r18	// bit 4=~address-bit(61)
> +(p10)	sub r19=r19,r26
> +(p10)	mov cr.itir=r25
>  	cmp.ne p8,p0=r0,r23

This look somewhat familiar. Any chance that you could merge my mods to 
the alt_dtlb_miss handler? Both have to modify ITIR. 

Also there may be a conflict since we both use high address bits?
