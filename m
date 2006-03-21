From: Yasunori Goto <y-goto@jp.fujitsu.com>
Date: Tue, 21 Mar 2006 04:11:53 +0000
Subject: Re: [PATCH: 017/017]Memory hotplug for new nodes v.4.(arch_register_node() for ia64)
Message-Id: <20060321130425.E477.Y-GOTO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060320183634.7E9C.Y-GOTO@jp.fujitsu.com> <1142872744.10906.125.camel@localhost.localdomain>
In-Reply-To: <1142872744.10906.125.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-mm <linux-mm@kvack.org>

> On Mon, 2006-03-20 at 18:57 +0900, Yasunori Goto wrote:
> > Current i386's code treats "parent node" in arch_register_node(). 
> > But, IA64 doesn't need it.
> 
> I'm not sure I understand.  What do you mean by "treats"?

Oops. My English may be wrong. :-(
I mean that i386 seems trying to make relationship of parent and child
among each node.

-- 
Yasunori Goto 


