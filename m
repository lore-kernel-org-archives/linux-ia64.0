From: Greg KH <greg@kroah.com>
Date: Wed, 22 Dec 2004 21:07:20 +0000
Subject: Re: [PATCH] add legacy resources to sysfs
Message-Id: <20041222210720.GA1867@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200412211247.44883.jbarnes@engr.sgi.com> <1103733278.31693.83.camel@gaston> <200412220858.18287.jbarnes@engr.sgi.com> <200412221031.52026.jbarnes@engr.sgi.com>
In-Reply-To: <200412221031.52026.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesse Barnes <jbarnes@engr.sgi.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, willy@debian.org, Bjorn Helgaas <bjorn.helgaas@hp.com>

On Wed, Dec 22, 2004 at 10:31:51AM -0800, Jesse Barnes wrote:
> Here's one with additions to the cleanup routine.  Please check it out to make 
> sure it's ok.  I moved around some functions to avoid having to prototype 
> them at the top of the file.
> 
> This patch adds legacy_io and legacy_mem files to the pci_bus class hierarchy 
> in sysfs.  The files can be used (if the platform supports them) to access 
> legacy I/O port space and legacy ISA memory space--useful for things like x86 
> emulators or VGA card POSTing.  The interfaces are documented in 
> Documentation/filesystems/sysfs-pci.txt.

Yeah, we finally got there, thanks for your patience!

Applied to my trees, thanks.

greg k-h
