From: Greg KH <greg@kroah.com>
Date: Thu, 22 Dec 2005 20:19:04 +0000
Subject: Re: [PATCH 1/3] msi vector targeting abstractions
Message-Id: <20051222201904.GC13901@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051222171616.8240.37671.12506@lnx-maule.americas.sgi.com> <20051222171621.8240.71918.22618@lnx-maule.americas.sgi.com> <20051222195814.GA14332@kroah.com> <20051222200916.GG17552@sgi.com>
In-Reply-To: <20051222200916.GG17552@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mark Maule <maule@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>

On Thu, Dec 22, 2005 at 02:09:16PM -0600, Mark Maule wrote:
> On Thu, Dec 22, 2005 at 11:58:14AM -0800, Greg KH wrote:
> > On Thu, Dec 22, 2005 at 11:15:13AM -0600, Mark Maule wrote:
> > > Abstract portions of the MSI core for platforms that do not use standard
> > > APIC interrupt controllers.  This is implemented through a new arch-specific
> > > msi setup routine, and a set of msi ops which can be set on a per platform
> > > basis.
> > > 
> > > Signed-off-by: Mark Maule <maule@sgi.com>
> > 
> > Hm, care to CC: the linux-pci and pci maintainer next time?  And you
> > also might want to run this by the original MSI authors...
> 
> I did run an early version of the patches across the original MSI authors, but
> much has changed since then.

Then why would you want to keep them out of the loop now, after much
change?  :)

> I didn't realize that there were lists other than linux-kernel and linux-ia64
> that needed to be cross posted, so my bad.  I'll resend with those additional
> lists.

Thanks, I appreciate it.

greg k-h
