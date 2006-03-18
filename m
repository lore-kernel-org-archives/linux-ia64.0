From: Matt Domsch <Matt_Domsch@dell.com>
Date: Sat, 18 Mar 2006 15:43:20 +0000
Subject: Re: [PATCH 2.6.15] ia64: use i386 dmi_scan.c
Message-Id: <20060318154319.GB29862@humbolt.us.dell.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060104221627.GA26064@lists.us.dell.com> <20060106172140.GB19605@lists.us.dell.com> <20060106223932.GB9230@lists.us.dell.com> <20060317155445.602f07b9.akpm@osdl.org> <20060318145621.GA29862@humbolt.us.dell.com>
In-Reply-To: <20060318145621.GA29862@humbolt.us.dell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: linux-ia64@vger.kernel.org, ak@suse.de, openipmi-developer@lists.sourceforge.net, matthew.e.tolentino@intel.com, linux-kernel@vger.kernel.org

On Sat, Mar 18, 2006 at 08:56:21AM -0600, Matt Domsch wrote:
> On Fri, Mar 17, 2006 at 03:54:45PM -0800, Andrew Morton wrote:
> > It could be that Andi's changes break the ia64 dmi impementation - I don't
> > know.  I guess it's OK if ia64 is not doing a scan "early".
> 
> It's not done "early", because at this point it's only needed for
> drivers.  On i386 it's done "early" to catch some chipsets
> (coincidentally, Dell).
> 
> > The above might not compile, but I'll make sure that it does so before
> > releasing next -mm.
> > 
> > So.  Bottom line: please test the ia64 dmi patches in next -mm, send any
> > needed fixups, thanks.
> 
> 
> Built 2.6.16-rc6-mm2 on ia64 Itanium2 (Dell PowerEdge 7250, aka Intel
> Tiger4).  Compiled clean, loaded clean, works as expected.  Thanks!

Built 2.6.16-rc6-mm2 on x86_64 Dell PowerEdge 2800.  Compiled clean,
loaded clean, works as expected.  Thanks!

-Matt

--
Matt Domsch
Software Architect
Dell Linux Solutions linux.dell.com & www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com
