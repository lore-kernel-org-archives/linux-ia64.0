From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 15 Dec 2004 23:15:51 +0000
Subject: Re: [PATCH] add legacy I/O and memory access routines to /proc/bus/pci API
Message-Id: <200412151515.51450.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200412140941.56116.jbarnes@engr.sgi.com> <200412150927.51733.jbarnes@engr.sgi.com> <20041215210346.GK9923@schnapps.adilger.int>
In-Reply-To: <20041215210346.GK9923@schnapps.adilger.int>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andreas Dilger <adilger@clusterfs.com>
Cc: linux-pci@atrey.karlin.mff.cu, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, bjorn.helgaas@hp.com

On Wednesday, December 15, 2004 1:03 pm, Andreas Dilger wrote:
> On Dec 15, 2004  09:27 -0800, Jesse Barnes wrote:
> > +write
> > +  Legacy I/O port space reads and writes must also be to a file
> > +  position >64k--the kernel will route them to the target device.
>
> Shouldn't that be < 64k based on the description of lseek?

Err.. yes

> > +lseek
> > +  Can be used to set the current file position.  Note that the file
> > +  size is limited to 64k as that's how big legacy I/O space is.
> >
> > +ioctl
> > +  Note that not all architectures support the *_MMAP_* or *_RW_* ioctl
> > +  commands.  If they're not supported, ioctl will return -EINVAL.
>
> Shouldn't they return -ENOTTY?  That indicates to the caller that the
> ioctl isn't handled, vs -EINVAL which indicates bad value being passed
> (e.g. bad write size).

Maybe, but that's not how /proc/bus/pci behaves right now...

Jesse
