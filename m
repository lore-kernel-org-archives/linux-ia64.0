From: "Magenheimer, Dan (HP Labs Fort Collins)" <dan.magenheimer@hp.com>
Date: Fri, 07 Oct 2005 19:27:33 +0000
Subject: RE: PATCH: Fix 2.6 kernel for the new ia64 assembler
Message-Id: <516F50407E01324991DD6D07B0531AD572EE27@cacexc12.americas.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051007180119.GA11645@lucon.org>
In-Reply-To: <20051007180119.GA11645@lucon.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Will the fixed code work on both old and new assemblers?
If not, isn't there a potential gcc/kernel version mismatch
problem?

> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org 
> [mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of James E Wilson
> Sent: Friday, October 07, 2005 12:20 PM
> Cc: linux ia64 kernel
> Subject: Re: PATCH: Fix 2.6 kernel for the new ia64 assembler
> 
> On Fri, 2005-10-07 at 11:01, H. J. Lu wrote:
> > The new ia64 assembler uses slot 1 for the offset of a long (2-slot)
> > instruction and the old assembler uses slot 2. The 2.6 
> kernel assumes
> > slot 2 and won't boot when the new assembler is used:
> 
> Specifically, this is in reference to tags occurring 
> immediately before
> a long instruction.
> 
> Given something like
> 	.text
> 	nop
> [L1:]
> 	movl
> The value of L1 should be .text+1 but it was incorrectly .text+2 until
> about 2 weeks ago.  Unfortunately, there is code in the kernel that
> relies on the incorrect value, and needs to be fixed.  H.J.'s patch
> fixes this.
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe 
> linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
