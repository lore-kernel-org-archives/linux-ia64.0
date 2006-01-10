From: Christoph Hellwig <hch@infradead.org>
Date: Tue, 10 Jan 2006 17:03:39 +0000
Subject: Re: [PATCH 0/3] msi abstractions and support for altix
Message-Id: <20060110170339.GA2567@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051222201651.2019.37913.96422@lnx-maule.americas.sgi.com> <20051222202259.GA4959@suse.de> <20051222202627.GI17552@sgi.com> <20051222203415.GA28240@suse.de> <20051222203824.GJ17552@sgi.com> <20051222205023.GK2361@parisc-linux.org> <20060103032249.GA4957@sgi.com> <20060103060719.GA1845@suse.de> <20060110170032.GC18399@sgi.com>
In-Reply-To: <20060110170032.GC18399@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mark Maule <maule@sgi.com>
Cc: Greg KH <gregkh@suse.de>, Matthew Wilcox <matthew@wil.cx>, linuxppc64-dev@ozlabs.org, linux-pci@atrey.karlin.mff.cuni.cz, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>

> Ok, looks like it's going to be a bit until I have time to work on the
> vector allocation stuff.
> 
> In the mean time, would folks be recepteive to taking this portion of the
> initial patchset:
> 
> [PATCH 1/4] msi archetecture init hook
> http://lkml.org/lkml/2005/12/21/168
> 
> This would at least give us a graceful pci_enable_msi() failure on altix
> until I find the time to work on the other stuff.

Personally I think your patchkit should just go in after all the other
comments have addresses [1].  It's a huge improvement over the mess that's
there currently.

[1] I don't remember if you posted a patchkit addressing everything else yet,
so maybe it's been done already.
