From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 16 Dec 2004 17:42:20 +0000
Subject: Re: [PATCH] add legacy I/O port & memory APIs to /proc/bus/pci
Message-Id: <200412160942.20678.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200412160850.20223.jbarnes@engr.sgi.com> <200412161037.55293.bjorn.helgaas@hp.com>
In-Reply-To: <200412161037.55293.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-pci@atrey.karlin.mff.cuni.cz
Cc: Bjorn Helgaas <bjorn.helgaas@hp.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, willy@debian.org

On Thursday, December 16, 2004 9:37 am, Bjorn Helgaas wrote:
> On Thursday 16 December 2004 9:50 am, Jesse Barnes wrote:
> > This patch documents the /proc/bus/pci interface and adds some optional
> > architecture specific APIs for accessing legacy I/O port and memory
> > space. This is necessary on platforms where legacy I/O port space doesn't
> > 'soft fail' like it does on PCs, and is useful for systems that can route
> > legacy space to different PCI busses.
>
> But we didn't resolve anything with respect to multiple PCI domains,
> did we?  As far as I can see, /proc/bus/pci currently doesn't support
> multiple domains at all.  I don't like the idea of adding new stuff
> that we already know is insufficient for machines in the very near
> future.  True, it's just extending an existing interface, but it
> seems like if we're going to the trouble of changing X, we might as
> well address multiple domains at the same time.

The problem with adding domain support is that it'll break existing users, 
unless it's added on the side somehow.  One thought I had was to document 
that /proc/bus/pci/ contains only busses from domain 0.  Machines with more 
than 1 domain could create /proc/bus/pci/domain/DDDD directories with busses 
in the DDDD domain underneath.  That wouldn't break existing applications, 
and would let you get at domains other than 0 if you needed to.

Jesse
