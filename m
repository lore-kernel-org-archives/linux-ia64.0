From: Dave Hansen <haveblue@us.ibm.com>
Date: Fri, 10 Feb 2006 16:33:18 +0000
Subject: Re: [Lhms-devel] [RFC/PATCH: 002/010] Memory hotplug for new nodes
Message-Id: <1139589198.9209.82.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060210223841.C532.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20060210223841.C532.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>, linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, x86-64 Discuss <discuss@x86-64.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>

On Fri, 2006-02-10 at 23:20 +0900, Yasunori Goto wrote:
> This patch is to initialize wait table and zonelists for new pgdat.
> When new node is added, free_area_init_node() is called to initialize
> pgdat. But, wait table must be allocated by kmalloc (not bootmem) for
> it.
> And, zonelists is accessed from any other process every time,
> So, stop_machine_run() is used for safety update.

I do notice that you're not using init_currently_empty_zone() to
initialize currently empty zones.  Why?

-- Dave

