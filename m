From: jbarnes@sgi.com (Jesse Barnes)
Date: Tue, 16 Mar 2004 17:38:51 +0000
Subject: Re: [PATCH] Update SN2 defconfig
Message-Id: <20040316173851.GB29899@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040315190240.GY6699@localhost>
In-Reply-To: <20040315190240.GY6699@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 16, 2004 at 09:36:28AM -0700, Bjorn Helgaas wrote:
> On Monday 15 March 2004 11:14 pm, David Mosberger wrote:
> > The ia64 EARLY_PRINTK support is not part of the official kernel, so
> > they should be lost to avoid warnings (if someone wanted to integrate
> > the ia64 EARLY_PRINTK patch with the other early-printk support in the
> > kernel, that would certainly be welcome, though).
> 
> I'm cooking some stuff in this area.  I think it will give us the
> equivalent of early printk pretty much for free.  It doesn't help
> with SGI boxes, though, because they have the funny console ;-)
> I'll try to post a preliminary patch today or tomorrow.

Our console should work very early on (our driver supports a polling
mode that should allow this), so hopefully we can reuse your work...

Thanks,
Jesse
