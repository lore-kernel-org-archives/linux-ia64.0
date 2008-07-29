From: Vivek Goyal <vgoyal@redhat.com>
Date: Tue, 29 Jul 2008 13:53:05 +0000
Subject: Re: [PATCH 3/5] ia64: Define elfcorehdr_addr in arch dependent
Message-Id: <20080729135305.GL25975@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080727234529.GM6175@verge.net.au> <20080728015117.GA12055@verge.net.au> <20080728024526.GB3334@verge.net.au> <20080728034007.GA30450@verge.net.au> <20080728211025.GA9985@redhat.com> <20080728211156.GB9985@redhat.com> <20080728211314.GC9985@redhat.com> <20080729044241.GA23514@verge.net.au>
In-Reply-To: <20080729044241.GA23514@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Muli Ben-Yehuda <muli@il.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Chandru <chandru@in.ibm.com>, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, Terry Loftin <terry.loftin@hp.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, Paul Mundt <lethal@linux-sh.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@ozlabs.org

On Tue, Jul 29, 2008 at 02:42:43PM +1000, Simon Horman wrote:
> On Mon, Jul 28, 2008 at 05:13:14PM -0400, Vivek Goyal wrote:
> > 
> > o Move elfcorehdr_addr definition in arch dependent crash dump file. This is
> >   equivalent to defining elfcorehdr_addr under CONFIG_CRASH_DUMP instead of
> >   CONFIG_PROC_VMCORE. This is needed by is_kdump_kernel() which can be
> >   used irrespective of the fact whether CONFIG_PROC_VMCORE is enabled or
> >   not.
> > 
> > Signed-off-by: Vivek Goyal <vgoyal@redhat.com>
> > ---
> > 
> >  arch/ia64/kernel/setup.c |    9 ++++++++-
> >  1 file changed, 8 insertions(+), 1 deletion(-)
> > 
> > diff -puN arch/ia64/kernel/setup.c~fix-elfcorehdr_addr-parsing-ia64 arch/ia64/kernel/setup.c
> > --- linux-2.6.27-pre-rc1/arch/ia64/kernel/setup.c~fix-elfcorehdr_addr-parsing-ia64	2008-07-28 12:16:40.000000000 -0400
> > +++ linux-2.6.27-pre-rc1-root/arch/ia64/kernel/setup.c	2008-07-28 12:16:40.000000000 -0400
> > @@ -478,7 +478,12 @@ static __init int setup_nomca(char *s)
> >  }
> >  early_param("nomca", setup_nomca);
> >  
> > -#ifdef CONFIG_PROC_VMCORE
> > +/*
> > + * Note: elfcorehdr_addr is not just limited to vmcore. It is also used by
> > + * is_kdump_kernel() to determine if we are booting after a panic. Hence
> > + * ifdef it under CONFIG_CRASH_DUMP and not CONFIG_PROC_VMCORE.
> > + */
> > +#ifdef CONFIG_CRASH_DUMP
> >  /* elfcorehdr= specifies the location of elf core header
> >   * stored by the crashed kernel.
> >   */
> > @@ -491,7 +496,9 @@ static int __init parse_elfcorehdr(char 
> >  	return 0;
> >  }
> >  early_param("elfcorehdr", parse_elfcorehdr);
> > +#endif
> >  
> > +#ifdef CONFIG_PROC_VMCORE
> >  int __init reserve_elfcorehdr(unsigned long *start, unsigned long *end)
> >  {
> >  	unsigned long length;
> > _
> 
> Hi Vivek,
> 
> I think that you also need the following in arch/ia64/kernel/crash_dump.c.
> With this change your code compiles on ia64.
> 
> Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> 

Thanks Simon. I had done these changes locally but somehow forgot to
include the changes in patches.

I will include these changes in my next posting of consolidated single
patch.

Thanks
Vivek
