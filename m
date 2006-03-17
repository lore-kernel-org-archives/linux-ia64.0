From: Mark Maule <maule@sgi.com>
Date: Fri, 17 Mar 2006 01:18:27 +0000
Subject: Re: [PATCH] (-mm) drivers/pci/msi: explicit declaration of msi_register
Message-Id: <20060317011827.GD13666@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44172F0E.6070708@ce.jp.nec.com> <20060314134535.72eb7243.akpm@osdl.org> <44176502.9050109@ce.jp.nec.com> <20060315235544.GA6504@suse.de> <44198210.6090109@ce.jp.nec.com> <20060316181934.GM13666@sgi.com> <20060316234118.GB9746@esmail.cup.hp.com> <20060316234906.GA24675@suse.de> <20060317004108.GH9746@esmail.cup.hp.com>
In-Reply-To: <20060317004108.GH9746@esmail.cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Grant Grundler <iod00d@hp.com>
Cc: Greg KH <gregkh@suse.de>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, shaohua.li@intel.com

On Thu, Mar 16, 2006 at 04:41:08PM -0800, Grant Grundler wrote:
> On Thu, Mar 16, 2006 at 03:49:06PM -0800, Greg KH wrote:
> > > There are other transaction based interrupt subsystems that are typically
> > > arch specific (e.g. GSC device interrupts on PA-RISC). So far, MSI is the
> > > only generic one and that is clearly part of the PCI spec. 
> > 
> > Yes, that's fine.  But the core pci msi structures do not need to be
> > exported for the whole kernel to see, right?  That's my only point here.
> 
> Yes, got it. I agree.
> 

Ok, I'll move the SN stuff down into pci/drivers.  I think that's ok, and
still allow the separation we want.  Basicly there's [almost] generic
msi core code (msi.c) and platform dependent interrupt controllers
(msi-apic.c and soon msi-altix.c).

Mark
