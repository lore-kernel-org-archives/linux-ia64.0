From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 22 Dec 2004 16:34:37 +0000
Subject: Re: [PATCH] add legacy resources to sysfs
Message-Id: <1103733278.31693.83.camel@gaston>
List-Id: <linux-ia64.vger.kernel.org>
References: <200412211247.44883.jbarnes@engr.sgi.com>
	 <20041221214623.GB10362@kroah.com> <1103704739.28670.57.camel@gaston>
	 <20041222160952.GB9358@kroah.com>
In-Reply-To: <20041222160952.GB9358@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg KH <greg@kroah.com>
Cc: Jesse Barnes <jbarnes@engr.sgi.com>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, willy@debian.org, Bjorn Helgaas <bjorn.helgaas@hp.com>

On Wed, 2004-12-22 at 08:09 -0800, Greg KH wrote:

> Hm, what do you mean by "instance"?  My /sys/class/pci_bus has the
> individual pci busses:
>  $ tree /sys/class/pci_bus/
>  /sys/class/pci_bus/
>  |-- 0000:00
>  |   |-- bridge -> ../../../devices/pci0000:00
>  |   `-- cpuaffinity
>  |-- 0000:01
>  |   |-- bridge -> ../../../devices/pci0000:00/0000:00:01.0
>  |   `-- cpuaffinity
>  `-- 0000:02
>      |-- bridge -> ../../../devices/pci0000:00/0000:00:1e.0
>      `-- cpuaffinity
> 
> 
> We already have the cpuaffinity stuff in there, why not more, pci bus
> specific things?

Oh, I misread. If it's in /sys/class/pci_bus/(instance)/file it's fine,
sorry, my fault.

Ben.


