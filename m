From: Greg KH <greg@kroah.com>
Date: Fri, 20 Jan 2006 02:15:28 +0000
Subject: Re: [PATCH 1/3] msi vector targeting abstractions
Message-Id: <20060120021528.GA19201@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060119194647.12213.44658.14543@lnx-maule.americas.sgi.com> <20060119194652.12213.96503.19247@lnx-maule.americas.sgi.com>
In-Reply-To: <20060119194652.12213.96503.19247@lnx-maule.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mark Maule <maule@sgi.com>
Cc: linuxppc64-dev@ozlabs.org, linux-pci@atrey.karlin.mff.cuni.cz, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>, gregkh@suse.de

On Thu, Jan 19, 2006 at 01:46:52PM -0600, Mark Maule wrote:
> Abstract portions of the MSI core for platforms that do not use standard
> APIC interrupt controllers.  This is implemented through a new arch-specific
> msi setup routine, and a set of msi ops which can be set on a per platform
> basis.
> 
> Signed-off-by: Mark Maule <maule@sgi.com>

Note that I changed this patch a bunch, rearanging where things went
(should not have touched include/linux/pci.h for this change) and
everything builds properly still on i386.  You should check that they
build on ia64 now too.

thanks,

greg k-h
