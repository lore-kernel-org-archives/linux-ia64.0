From: Erich Focht <efocht@hpce.nec.com>
Date: Wed, 16 Jul 2003 19:56:32 +0000
Subject: Re: [Discontig-devel] [PATCH] another discontig patch
Message-Id: <marc-linux-ia64-105838539529805@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105618641519753@msgid-missing>
In-Reply-To: <marc-linux-ia64-105618641519753@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 16 July 2003 21:40, Matthew Wilcox wrote:
> On Wed, Jul 16, 2003 at 12:29:52PM -0700, Jesse Barnes wrote:
> > @@ -210,8 +210,8 @@
> >  	  system with an A0 or A1 stepping CPU.
> >
> >  config NUMA
> > -	bool "Enable NUMA support" if IA64_GENERIC || IA64_DIG || IA64_HP_ZX1
> > -	default y if IA64_SGI_SN2
> > +	bool
> > +	default y if IA64_SGI_SN2 || IA64_GENERIC
> >  	help
> >  	  Say Y to compile the kernel to support NUMA (Non-Uniform Memory
> >  	  Access).  This option is for configuring high-end multiprocessor

There are other NUMA machines around which are not from SGI and are
IA64_DIG. You excluded them on purpose? I hope not...

> If you're removing the question, you can remove the helptext too.
>
> > @@ -235,8 +235,7 @@
> >
> >  config DISCONTIGMEM
> >  	bool
> > -	depends on IA64_SGI_SN2 || (IA64_GENERIC || IA64_DIG || IA64_HP_ZX1) &&
> > NUMA -	default y
> > +	default y if IA64_SGI_SN2 || IA64_GENERIC
> >  	help
> >  	  Say Y to support efficient handling of discontiguous physical memory,
> >  	  for architectures which are either NUMA (Non-Uniform Memory Access)

Same comment as above. NEC TX7 is an IA64_DIG platform.

Erich


