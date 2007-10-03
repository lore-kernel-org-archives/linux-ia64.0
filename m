From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 03 Oct 2007 04:57:02 +0000
Subject: Re: [Question] How to represent SYSTEM_RAM in kerenel/resouce.c
Message-Id: <20071003135702.bdcf3f1b.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071003103136.addbe839.kamezawa.hiroyu@jp.fujitsu.com>
	<20071003015242.GC12049@parisc-linux.org>
In-Reply-To: <20071003015242.GC12049@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: LKML <linux-kernel@vger.kernel.org>, andi@firstfloor.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, "tony.luck@intel.com" <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, pbadari@us.ibm.com, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

On Tue, 2 Oct 2007 19:52:42 -0600
Matthew Wilcox <matthew@wil.cx> wrote:

> On Wed, Oct 03, 2007 at 10:31:36AM +0900, KAMEZAWA Hiroyuki wrote:
> > i386 and x86_64 registers System RAM as IORESOUCE_MEM | IORESOUCE_BUSY.
> > ia64 registers System RAM as IORESOURCE_MEM.
> > 
> > Which is better ?
> 
> Should probably be BUSY.  Non-BUSY regions can have io resources
> requested underneath them, but you wouldn't want a PCI device to be
> assigned an address which overlaps with physical memory.

Thank you.
It seems that I'll have to try modifing ia64 and memory hotplug in
the next -mm. 

Regards,
-Kame

