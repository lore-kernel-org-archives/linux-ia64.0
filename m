From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 22 Dec 2004 08:38:59 +0000
Subject: Re: [PATCH] add legacy resources to sysfs
Message-Id: <1103704739.28670.57.camel@gaston>
List-Id: <linux-ia64.vger.kernel.org>
References: <200412211247.44883.jbarnes@engr.sgi.com>
	 <20041221214623.GB10362@kroah.com>
In-Reply-To: <20041221214623.GB10362@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg KH <greg@kroah.com>
Cc: Jesse Barnes <jbarnes@engr.sgi.com>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, willy@debian.org, Bjorn Helgaas <bjorn.helgaas@hp.com>

On Tue, 2004-12-21 at 13:46 -0800, Greg KH wrote:
> On Tue, Dec 21, 2004 at 12:47:44PM -0800, Jesse Barnes wrote:
> > Here's a rediff against Greg's current tree.  It adds legacy_io and legacy_mem 
> > files to each PCI bus directory in sysfs for use by applications that want to 
> > do old school ISA style programming from userspace.
> > 
> > I'm not sure I've got the sysfs file creation correct, Greg?  Am I passing the 
> > wrong thing around?  The compile warnings in pci-sysfs.c for the new routines 
> > seem to indicate that...  Basically I need to get to a pci_bus structure from 
> > the read/write/mmap routines, and that should be accessible from the kobject 
> > somewhere, right?
> 
> You are passing the wrong things around :)
> 
> A struct pci_bus is a struct class_device, not a struct device.  I think
> you need to rethink your goal of putting the files into the pci device
> directory, or just put the files into the proper /sys/class/pci_bus/*
> directory as your code assumes is happening.

It makes no sense in /sys/class/pci_bus/* since we need the files to be
in a bus _instance_ 

Ben.


