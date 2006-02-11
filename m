From: Yasunori Goto <y-goto@jp.fujitsu.com>
Date: Sat, 11 Feb 2006 03:06:11 +0000
Subject: Re: [Lhms-devel] [RFC/PATCH: 001/010] Memory hotplug for new nodes with pgdat allocation. (pgdat all
Message-Id: <20060211120325.D358.Y-GOTO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060210223757.C530.Y-GOTO@jp.fujitsu.com> <1139588910.9209.73.camel@localhost.localdomain>
In-Reply-To: <1139588910.9209.73.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Hansen <haveblue@us.ibm.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>, linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>, x86-64 Discuss <discuss@x86-64.org>

> On Fri, 2006-02-10 at 23:20 +0900, Yasunori Goto wrote:
> > +        unsigned long size = arch_pernode_size(nid); 
> 
> Size in what?  Pages?  Bytes?  Meters? :)

Do you mean variable name is not appropriate?

Then, I'll change it to pernode_size, pernode_struct_size or
something. :-)

-- 
Yasunori Goto 


