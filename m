From: Yasunori Goto <y-goto@jp.fujitsu.com>
Date: Fri, 10 Feb 2006 01:49:06 +0000
Subject: Re: [Lhms-devel] [RFC:PATCH(000/003)] Memory add to onlined node. (ver. 2)
Message-Id: <20060210103730.AFC7.Y-GOTO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F05AA16C3@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F05AA16C3@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Andi Kleen <ak@suse.de>, "Brown, Len" <len.brown@intel.com>, "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>, "S, Naveen B" <naveen.b.s@intel.com>, Bjorn Helgaas <bjorn.helgaas@hp.com>, ACPI-ML <linux-acpi@vger.kernel.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, x86-64 Discuss <discuss@x86-64.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>

> > - if the node is already online.-  If the node is offline, 
> > (It means new node is comming!)  then the memory will belongs
> > to node 0 yet.
> 
> What is the long term plan to address this?  Can you make sure
> that the new node is always brought online before you get to
> this code?  Or will you have to bring the node online in the
> middle of the memory hot-add code?

I still have patches for new pgdat addtion,
But I was afraid that everyone think they are messy due to too much code.
So, I tried to post a part of them step by step.

Ok, I would like to try to rebase and repost them.
It might be good time for it now. :-)

Bye.
-- 
Yasunori Goto 


