From: Jack Steiner <steiner@sgi.com>
Date: Fri, 04 Jul 2003 01:42:41 +0000
Subject: Re: Reliably creating MCA on white box Itanium-1
Message-Id: <marc-linux-ia64-105728333228553@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105721395828393@msgid-missing>
In-Reply-To: <marc-linux-ia64-105721395828393@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 
> On Thu, 3 Jul 2003 08:27:36 -0500 (CDT), 
> Jack Steiner <steiner@sgi.com> wrote:
> >> 
> >> Is there a way of reliably creating an MCA on a white box Itanium 1?
> >> B3 processors, firmware is B117A.  Failing that, what about creating an
> >> MCA on a white box Itanium-2?
> >> 
> >> Loading a duplicate ITC is no good, I need an MCA that actually enters
> >> ia64_mca_ucmc_handler in mca.c.  A working example using
> >> PAL_CACHE_WRITE would be nice.
> >
> >
> >Why doesnt loading a duplicate TR (not TC) work for you?  I've used that
> >method and found it to be reliable. 
> 
> Because mca_asm.S does not call the C code for TLB errors.  I want to
> test the C code on standard hardware.

Seems to me that a TLB error caused by a duplicate TR dropin *should* call
C code.  A MCA caused by a duplicate TR is a software bug that should
panic the system. 

I understand that TLB parity errors would be silently corrected in mca_asm.S
by reloading the TLB. 


-- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com

