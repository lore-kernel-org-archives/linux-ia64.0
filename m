From: "Mallick, Asit K" <asit.k.mallick@intel.com>
Date: Wed, 10 Jan 2001 03:15:16 +0000
Subject: RE: [Linux-ia64] Kernel panic in dtlb_fault
Message-Id: <marc-linux-ia64-105590693005014@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205904@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205904@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The TLB code got re-arranged a bit and I will take a look at why the
DISABLE_VHPT is not working.

Thanks,
Asit


> -----Original Message-----
> From: Uros Prestor [mailto:uros@turbolinux.com]
> Sent: Tuesday, January 09, 2001 4:41 PM
> To: davidm@hpl.hp.com
> Cc: linux-ia64@linuxia64.org
> Subject: Re: [Linux-ia64] Kernel panic in dtlb_fault
> 
> 
> David Mosberger wrote:
> 
> >   Uros> The IP points inside the dtlb_fault code.  Any ideas what's
> >   Uros> going on here?  The panic happens both with SMP and UP
> >   Uros> kernels.  I have disabled the VHPT (CONFIG_DISABLE_VHPT=y).
> >   Uros> Anything else I am missing?
> >
> > I don't think I tested the kernel with DISABLE_VHPT.
> 
> Enabling VHPT solved the problem.
> 
> Thanks,
> Uros
> 
> --
> Uros Prestor
> uros@turbolinux.com
> 
> 
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 


