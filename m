From: Greg KH <gregkh@suse.de>
Date: Thu, 16 Mar 2006 23:28:37 +0000
Subject: Re: [PATCH] (-mm) drivers/pci/msi: explicit declaration of msi_register
Message-Id: <20060316232837.GA12408@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <44172F0E.6070708@ce.jp.nec.com> <20060314134535.72eb7243.akpm@osdl.org> <44176502.9050109@ce.jp.nec.com> <20060315235544.GA6504@suse.de> <44198210.6090109@ce.jp.nec.com> <20060316181934.GM13666@sgi.com> <4419BD64.5070705@ce.jp.nec.com> <20060316194155.GP13666@sgi.com>
In-Reply-To: <20060316194155.GP13666@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mark Maule <maule@sgi.com>
Cc: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, shaohua.li@intel.com

On Thu, Mar 16, 2006 at 01:41:55PM -0600, Mark Maule wrote:
> On Thu, Mar 16, 2006 at 02:32:52PM -0500, Jun'ichi Nomura wrote:
> > Hi Mark,
> > 
> > Thanks for the reply.
> > 
> > Mark Maule wrote:
> > >>There is another problem that CONFIG_IA64_GENERIC still doesn't
> > >>build due to error in SGI SN specific code.
> > >>It needs additional fix.
> > >
> > >Ok, looking back at some of my original patches, it seems like the
> > >declaration of msi_ops got moved from pci.h to and some forward 
> > >declarations
> > >in ia64/msi.h were removed.  This patch corrects the build problems.
> > 
> > But,
> > 
> > Greg said:
> > >these are core pci things that no one else should care about.
> > 
> > Andrew said:
> > >a declaration for msi_register(), in drivers/pci/pci.h.
> > > We don't want to add a duplicated declaration like this.
> > 
> > I think the idea already gets objections.
> > 
> > >The reason for putting struct msi_ops in pci.h is so that msi code that
> > >resides outside of drivers/pci can use the declaration without having to
> > >reach down into drivers/pci.
> > 
> > The code in arch/ia64/sn/pci/msi.c looks much like
> > drivers/pci/msi-apic.c.
> > Why don't you move them to drivers/pci/msi-sgi-sn.c or something?
> 
> I didn't do that originally 'cause I didn't think drivers/pci was the place
> for platform-specific code.
> 
> That said, I am not against moving sn/pci/msi.c into drivers if that is
> more acceptable than putting msi_ops into pci.h.

As msi.c today is pretty platform-specific as is, I don't have a problem
with moving the ia64 stuff also into that directory.  Especially as it
will help solve issues like this a lot better.

thanks,

greg k-h
