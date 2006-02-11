From: Yasunori Goto <y-goto@jp.fujitsu.com>
Date: Sat, 11 Feb 2006 03:08:26 +0000
Subject: Re: [Lhms-devel] [RFC/PATCH: 001/010] Memory hotplug for new nodes with pgdat allocation. (pgdat all
Message-Id: <20060211120739.D35A.Y-GOTO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060210223757.C530.Y-GOTO@jp.fujitsu.com> <1139589041.9209.77.camel@localhost.localdomain>
In-Reply-To: <1139589041.9209.77.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Hansen <haveblue@us.ibm.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>, linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>, x86-64 Discuss <discuss@x86-64.org>

> On Fri, 2006-02-10 at 23:20 +0900, Yasunori Goto wrote:
> > +       NODE_DATA(nid)->kswapd = kthread_create(kswapd, NODE_DATA(nid), "kswapd%d", nid); 
> 
> Can this fail?

Yes! I should check it. 
Thanks.

-- 
Yasunori Goto 


