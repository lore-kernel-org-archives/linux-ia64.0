From: "H . J . Lu" <hjl@valinux.com>
Date: Fri, 17 Nov 2000 17:01:10 +0000
Subject: Re: [Linux-ia64] toolchain status
Message-Id: <marc-linux-ia64-105590678205740@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205739@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205739@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Nov 17, 2000 at 03:55:30PM +0100, Francis Galiegue wrote:
> On Thu, 16 Nov 2000, H . J . Lu wrote:
> 
> > > > There is no DT_INIT_ARRAY in libc.so. Even if there is DT_INIT_ARRAY,
> > > > I still don't know how to use it to tell where DT_INIT points to.
> > > 
> > > Easy enough -- you know from DT_PLTGOT what the GP is for the DSO.
> > > If *(long *)(DT_INIT + 8) = GP, then you can assume that DT_INIT
> > > is a descriptor instead of an offset.
> > > 
> > 
> > Thanks. This patch seems to work for me.
> > 
> 
> I don't know which version this patch is supposed to apply to, but it doesn't
> apply as is on the stock FSF tree. "Corrected" patch for this tree is attached,
> in case it is of interest for someone.

Your patch looks wrong. Please check out the glibc 2.2 from CVS again.


-- 
H.J. Lu (hjl@valinux.com)

