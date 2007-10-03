From: Dave Hansen <haveblue@us.ibm.com>
Date: Wed, 03 Oct 2007 16:37:13 +0000
Subject: Re: [Question] How to represent SYSTEM_RAM in kerenel/resouce.c
Message-Id: <1191429433.4939.49.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071003103136.addbe839.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071003103136.addbe839.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, andi@firstfloor.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, "tony.luck@intel.com" <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, pbadari@us.ibm.com, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

On Wed, 2007-10-03 at 10:31 +0900, KAMEZAWA Hiroyuki wrote:
> 
> i386 and x86_64 registers System RAM as IORESOUCE_MEM |
> IORESOUCE_BUSY.
> ia64 registers System RAM as IORESOURCE_MEM.
> 
> Which is better ?

I think we should take system ram out of the iomem file, at least.

'struct resource' is a good, cross-platform structure to use for keeping
track of which memory we have where.  So, we can share that structure to
keep track of iomem, or memory hotplug state.  But, I'm not sure we
should be intermingling system RAM and iomem like we are now in the same
instance of the structure.

-- Dave

