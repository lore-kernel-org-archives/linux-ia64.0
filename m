From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 04 Mar 2004 00:40:16 +0000
Subject: Re: [patch] 2.4.25 sync unwind code with 2.6.3
Message-Id: <200403031740.16423.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3792.1077504388@kao2.melbourne.sgi.com>
In-Reply-To: <3792.1077504388@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 03 March 2004 5:09 pm, David Mosberger wrote:
> >>>>> On Wed, 3 Mar 2004 16:53:36 -0700, Bjorn Helgaas <bjorn.helgaas@hp.com> said:
> 
>  > -                       val = unw.preg_index[UNW_REG_F2  + (rval -  1)];
>  > +                       val = unw.preg_index[UNW_REG_F2  + (rval -  2)];
> 
>  > You didn't change this, but I'd feel better if I understood
>  > why this is different.
> 
> It was a typo.  The code is needed to handle f2-f5, hence the "- 2".

Ah, and I bet that's the one you mentioned on 2/23 with this link:
  http://lia64.bkbits.net:8080/to-linus-2.5/cset@1.1659
(which no longer points the right place -- rats, bitten again by
the fact that BK cset numbers change after the fact :-()

Thanks for straightening me out.  I'll apply the following patch to
2.4 so it will be the same as 2.6 in this regard:

=== arch/ia64/kernel/unwind.c 1.30 vs edited ==--- 1.30/arch/ia64/kernel/unwind.c	Wed Mar  3 16:51:27 2004
+++ edited/arch/ia64/kernel/unwind.c	Wed Mar  3 17:33:27 2004
@@ -1420,7 +1420,7 @@
 
 	      case UNW_WHERE_FR:
 		if (rval <= 5)
-			val = unw.preg_index[UNW_REG_F2  + (rval -  1)];
+			val = unw.preg_index[UNW_REG_F2  + (rval -  2)];
 		else if (rval >= 16 && rval <= 31)
 			val = unw.preg_index[UNW_REG_F16 + (rval - 16)];
 		else {

