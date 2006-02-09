From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 09 Feb 2006 17:04:43 +0000
Subject: RE: [Lhms-devel] [RFC:PATCH(000/003)] Memory add to onlined node. (ver. 2)
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05AA16C3@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yasunori Goto <y-goto@jp.fujitsu.com>, Andi Kleen <ak@suse.de>, "Brown, Len" <len.brown@intel.com>, "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>, "S, Naveen B" <naveen.b.s@intel.com>, Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: ACPI-ML <linux-acpi@vger.kernel.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, x86-64 Discuss <discuss@x86-64.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>

> - if the node is already online.-  If the node is offline, 
> (It means new node is comming!)  then the memory will belongs
> to node 0 yet.

What is the long term plan to address this?  Can you make sure
that the new node is always brought online before you get to
this code?  Or will you have to bring the node online in the
middle of the memory hot-add code?

Presumably there is a similar issue with hot add cpu.

-Tony
