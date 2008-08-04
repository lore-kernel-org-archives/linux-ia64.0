From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Mon, 04 Aug 2008 03:08:43 +0000
Subject: Re: Problem booting on some HP systems
Message-Id: <20080804030843.GF19331%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <57C9024A16AD2D4C97DC78E552063EA3082ABE01@orsmsx505.amr.corp.intel.com>
In-Reply-To: <57C9024A16AD2D4C97DC78E552063EA3082ABE01@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Aug 01, 2008 at 06:43:08PM -0500, James Bottomley wrote:
> On Fri, 2008-08-01 at 16:24 -0700, Luck, Tony wrote:
> > Recent kernels are not booting on some HP systems (though
> > it does boot on others).  James spent time and tracked it
> > to this patch in the pvops series:
> > 
> > commit 498c5170472ff0c03a29d22dbd33225a0be038f4
> > Author: Isaku Yamahata <yamahata@valinux.co.jp>
> > Date:   Mon May 19 22:13:38 2008 +0900
> > 
> >     [IA64] pvops: paravirtualize ivt.S
> > 
> > I did a quick compile with and without this patch applied and
> > compared the diassembled ivt.o file and spotted two places
> > where an _FROM_ macro had been used where _TO_ was intended.
> > See the <<<<< OOPS below:
> > 
> > 
> > @@ -1360,26 +1357,26 @@ ENTRY(speculation_vector)
> >          *
> >          * cr.imm contains zero_ext(imm21)
> >          */
> > -       mov r18=cr.iim
> > +       MOV_FROM_IIM(r18)
> >         ;;
> > -       mov r17=cr.iip
> > +       MOV_FROM_IIP(r17)
> >         shl r18=r18,43                  // put sign bit in position (43d-21)
> >         ;;
> > 
> > -       mov r16=cr.ipsr
> > +       MOV_FROM_IPSR(p0, r16)
> >         shr r18=r18,39                  // sign extend (39C-4)
> >         ;;
> > 
> >         add r17=r17,r18                 // now add the offset
> >         ;;
> > -       mov cr.iip=r17
> > +       MOV_FROM_IIP(r17) <<<<<<< OOPS!
> >         dep r16=0,r16,41,2              // clear EI
> >         ;;
> > 
> > -       mov cr.ipsr=r16
> > +       MOV_FROM_IPSR(p0, r16) <<<<<<<< OOPS!
> >         ;;
> > 
> > -       rfi                             // and go back
> > +       RFI
> >  END(speculation_vector)
> > 
> > 
> > I don't know whether these are the cause of the problems on James'
> > and Willy's machines (could you try swapping these round please?)
> 
> Actually tony traced this to errors in the statements by comparing
> disassembled output.  There's two register moves that are now the wrong
> way around.  Applying this patch gets my system booting again.
> 
> James
> 
> ---
> 
> diff --git a/arch/ia64/kernel/ivt.S b/arch/ia64/kernel/ivt.S
> index c39627d..b8750a0 100644
> --- a/arch/ia64/kernel/ivt.S
> +++ b/arch/ia64/kernel/ivt.S
> @@ -1243,11 +1243,11 @@ ENTRY(speculation_vector)
>  
>  	add r17=r17,r18			// now add the offset
>  	;;
> -	MOV_FROM_IIP(r17)
> +	MOV_TO_IIP(r17, p0)
>  	dep r16=0,r16,41,2		// clear EI
>  	;;
>  
> -	MOV_FROM_IPSR(p0, r16)
> +	MOV_TO_IPSR(p0, r16, p0)
>  	;;
>  
>  	RFI

Ouch. Sorry for those.
The last argument for those macro should be regular register.
Here is the patch.


From cc61356b6cb83aad5e798c402fe2a323953bb3de Mon Sep 17 00:00:00 2001
From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Mon, 4 Aug 2008 12:02:28 +0900
Subject: [PATCH] [IA64] pv_ops: fix ivt.S paravirtualization

Recent kernels are not booting on some HP systems (though
it does boot on others).
Two instructions were wrongly paravirtualized such that
an _FROM_ macro had been used where _TO_ was intended
by c/s 498c5170472ff0c03a29d22dbd33225a0be038f4.
This patch fixes them.

Cc: "Luck, Tony" <tony.luck@intel.com>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: "Wilcox, Matthew  R" <matthew.r.wilcox@intel.com>
Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/ivt.S |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/kernel/ivt.S b/arch/ia64/kernel/ivt.S
index c39627d..416a952 100644
--- a/arch/ia64/kernel/ivt.S
+++ b/arch/ia64/kernel/ivt.S
@@ -1243,11 +1243,11 @@ ENTRY(speculation_vector)
 
 	add r17=r17,r18			// now add the offset
 	;;
-	MOV_FROM_IIP(r17)
+	MOV_TO_IIP(r17, r19)
 	dep r16=0,r16,41,2		// clear EI
 	;;
 
-	MOV_FROM_IPSR(p0, r16)
+	MOV_TO_IPSR(p0, r16, r19)
 	;;
 
 	RFI
-- 
1.6.0.rc0.42.g186458

-- 
yamahata
