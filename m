From: Matt Chapman <matthewc@cse.unsw.edu.au>
Date: Sat, 21 Jun 2003 06:58:59 +0000
Subject: Re: [Linux-ia64] sigaltstack and ar.bspstore
Message-Id: <marc-linux-ia64-105617883916733@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723706086@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723706086@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jun 20, 2003 at 11:05:30PM -0700, David Mosberger wrote:
> >>>>> On Sat, 31 May 2003 00:18:39 +1000, Matt Chapman <matthewc@cse.unsw.edu.au> said:
> 
>   Matt> Currently when using an alternate stack for signal handling,
>   Matt> the trampoline code switches to the new register stack without
>   Matt> saving bspstore.  When returning to the original register
>   Matt> stack, it calculates the bspstore as:
> 
>   Matt>   bspstore0 = rse_skip_regs(bsp0, -rse_num_regs(bsp1 - (loadrs
>   Matt> >> 19), bsp1)); where bsp0 is sc->sc_ar_bsp and bsp1 is the
>   Matt> current bsp
> 
>   Matt> Presumably the result should be the same as the original
>   Matt> bspstore.  However, it isn't in the case when the original
>   Matt> bspstore is pointing to slot 63 (the RNAT word).  The new
>   Matt> bspstore comes out pointing to slot 0 of the next group, and
>   Matt> the RNAT bits never get written.
> 
> Yes, this is a problem.  Can you try the attached patch?  Rather than
> storing an additional sc_bspstore member, the backing-store switching
> code checks whether bspstore points to an RNaT slot and, if so, stores
> the RNaT manually.  This effectively "normalizes" the backing-store
> such that ar.bspstore never points to an RNaT slot.

Ah, that's a good way of doing it (given the constraints of backwards
compatibility).  I've tested your patch and it works well for me.

Thanks!

Matt


_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64
