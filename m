From: Jack Steiner <steiner@sgi.com>
Date: Fri, 15 Aug 2003 17:36:09 +0000
Subject: Re: Add ia64_tpa & ia64_imva for 2.4.21
Message-Id: <marc-linux-ia64-106096931201014@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106096639130452@msgid-missing>
In-Reply-To: <marc-linux-ia64-106096639130452@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 
> On Friday 15 August 2003 10:42 am, Jack Steiner wrote:
> > Because of the strange memory map on the SGI SN hardware, we need a 
> > portion of the 2.6 patches from Tony Luck backported into 2.4.21. 
> > 
> > This patche adds the ia64_imva function & a few additional calls to ia64_tpa.
> > 
> > In 2.6, these patches were part of the change to relocate the kernel to
> > region 5. However, I am NOT proposing making that change!!  I just need the
> > macros!!
> 
> I applied this for 2.4, except for this bit:
> 
> > +#define __imva(x) ((long)__va(ia64_tpa(x)))
> 
> because there was no reference to __imva().  If you need it for some
> SN-specific code, let me know.
> 
> Bjorn
> 

Not needed. That was an error on my part. I should have deleted that line.




-- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com

