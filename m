From: Matt Chapman <matthewc@cse.unsw.edu.au>
Date: Thu, 02 Oct 2003 02:10:54 +0000
Subject: Re: [PATCH] long format VHPT
Message-Id: <marc-linux-ia64-106506067204931@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106453902218848@msgid-missing>
In-Reply-To: <marc-linux-ia64-106453902218848@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Oct 02, 2003 at 11:51:35AM +1000, Peter Chubb wrote:
> 
> Aurn> Darren Williams wrote:
> >  
> > -#define ia64_rid(ctx,addr)	(((ctx) << 3) | (addr >> 61))
> > +#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
> > +#define redistribute_rid(rid)	(((rid) & ~0xffff) | (((rid) << 8) & 0xff00) | (((rid) >> 8) & 0xff))
> > +#else
> > +#define redistribute_rid(rid)	(rid)
> > +#endif
> > +#define ia64_rid(ctx,addr)	redistribute_rid(((ctx) << 3) | (addr >> 61))
> >  
> 
> Arun> Hi Darren, Can you explain what this code is trying to do ?
> 
> If I may comment....
> 
> The hash function that the VHPT uses works poorly for consecutive
> RIDs.  The redistribute_rid() macro flips around the low order bits to
> get something that hashes more evenly -- otherwise in the experiments
> we did, we saw major hash collision problems.

Yep.  The hash function on current processors is basically RID ^ VPN so
if you have close together RIDs and similar address space layout, which
is common (e.g. fork()) you get significant collision problems.  This was
a hack to space out the RIDs we present to the hardware without messing
with Linux's sequential allocation scheme.  Perhaps there is a better
place to do this.

Matt

