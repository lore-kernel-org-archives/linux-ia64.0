From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 10 Aug 2004 15:51:52 +0000
Subject: Re: r996 - in trunk/kernel/ia64/kernel-patch-2.6.7-ia64-2.6.7: . debian
Message-Id: <200408100851.52507.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040810071417.GA5080@lst.de>
In-Reply-To: <20040810071417.GA5080@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday, August 10, 2004 12:14 am, Christoph Hellwig wrote:
> > -diff -urN kernel-source-2.6.2.orig/arch/ia64/sn/Makefile
> > kernel-source-2.6.2/arch/ia64/sn/Makefile ----
> > kernel-source-2.6.2.orig/arch/ia64/sn/Makefile	2004-02-05
> > 01:19:28.000000000 -0700 -+++
> > kernel-source-2.6.2/arch/ia64/sn/Makefile	2004-02-15 01:38:43.000000000
> > -0700 -@@ -9,4 +9,4 @@
> > - # Makefile for the sn ia64 subplatform
> > - #
> > -
> > --obj-y += kernel/ io/
> > -+obj-$(CONFIG_DISCONTIGMEM) += kernel/ io/
> >
> > Copied: trunk/kernel/ia64/kernel-patch-2.6.7-ia64-2.6.7/up-fix.patch
> > (from rev 995,
> > trunk/kernel/ia64/kernel-patch-2.6.7-ia64-2.6.7/patch1.diff)

This little bit in particular doesn't make much sense to me.  
arch/ia64/sn/Makefile won't even be called unless we're building a generic 
kernel or an sn2 kernel, so why make it depend on config_discontigmem?  So 
you can build a generic-but-not-quite-generic kernel by turning off 
config_discontigmem?  I think there's a patch like this in the Fedora tree as 
well, it doesn't make sense there either, but Arjan wanted it so that we 
could benchmark the effect of turning on config_discontigmem in a generic 
kernel (it wasn't measurable).

Thanks,
Jesse
