From: Jesse Barnes <jbarnes@sgi.com>
Date: Wed, 15 Dec 2004 03:06:26 +0000
Subject: Re: [PATCH] add legacy I/O and memory access routines to /proc/bus/pci API
Message-Id: <200412141906.26809.jbarnes@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200412140941.56116.jbarnes@engr.sgi.com> <200412141655.04416.bjorn.helgaas@hp.com> <200412141611.32417.jbarnes@engr.sgi.com>
In-Reply-To: <200412141611.32417.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesse Barnes <jbarnes@engr.sgi.com>
Cc: Bjorn Helgaas <bjorn.helgaas@hp.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org

On Tuesday, December 14, 2004 4:11 pm, Jesse Barnes wrote:
> > In this example, the particular device ("01/01.0") you open
> > makes no difference, right?  The I/O port routing is determined
> > by the chipset, not by which /proc/bus/pci/... file you open.
>
> But the chipset can be programmed to route things correctly or remap the
> correct legacy I/O port domain in the callback routine.

I should clarify here, the device *does* matter, since the legacy I/O port 
space mapping will point at different addresses depending on the device.  
Generally, devices on the same bus will get the same address, but two devices 
on different busses will have different addresses mapped (at least on Altix).  
In your case, where you can route I/O ports to arbitrary busses, you could do 
the routing at the time of the call and return -EBUSY if another device was 
already using the route and hadn't released it yet.

Jesse
