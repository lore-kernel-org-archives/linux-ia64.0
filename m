From: "Mallick, Asit K" <asit.k.mallick@intel.com>
Date: Fri, 25 Jan 2002 22:57:09 +0000
Subject: RE: [Linux-ia64] Patch to fix latest kernels issue with FW83
Message-Id: <marc-linux-ia64-105590698805937@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805927@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805927@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


> -----Original Message-----
> From: Bjorn Helgaas [mailto:bjorn_helgaas@hp.com]
> Sent: Friday, January 25, 2002 8:08 AM
> To: Mallick, Asit K; linux-ia64@linuxia64.org
> Subject: Re: [Linux-ia64] Patch to fix latest kernels issue with FW83
> 
> 
> On Thursday 24 January 2002 12:46 pm, Mallick, Asit K wrote:
> > We have root caused the stability problem with latest 
> kernels and FW83
> > (LION platform). The following patch (based on 2.4.17) fixes the
> > problem.
> ...
> > -   "ld4.bias r2 = [%0]\n"                  \
> > +   "ld4 r2 = [%0]\n"                   \
> 
> Can you elaborate on this a bit?  All I know about ld.bias is 
> the statement
> in section 4.4.6.1 of Vol 1 that
> 
>     [ld.bias] is a hint to the implementation to acquire exclusive
>     ownership of the line containing the addressed data.  The bias
>     hint does not affect program functionality and may be ignored
>     by the implementation.

This is correcnt.

> 
> I can believe the patch is a performance optimization (my 
> intuition is that
> when the holder writes the lock to release it, the waiter will merely
> invalidate its shared line, where it previously had to invalidate and
> copyout its exclusive line), but I don't see how this should improve
> stability.  What am I missing?

FW83 does not have a workaround for a chipset issue (chipset SAC errata#2 in
460GX specification update) that could cause a livelock with ld.bias loops
and no modification. The later version of the FWs have the workaround and
will not see this problem.


Thanks,
Asit

