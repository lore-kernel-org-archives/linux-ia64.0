From: Dave Hansen <haveblue@us.ibm.com>
Date: Fri, 17 Mar 2006 17:12:18 +0000
Subject: Re: [PATCH: 002/017]Memory hotplug for new nodes v.4.(change name
Message-Id: <1142615538.10906.67.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060317162757.C63B.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20060317162757.C63B.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andrew Morton <akpm@osdl.org>, "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Fri, 2006-03-17 at 17:20 +0900, Yasunori Goto wrote:
> This patch changes name of old add_memory() to arch_add_memory.
> and use node id to get pgdat for the node at NODE_DATA().
> 
> Note: Powerpc's old add_memory() is defined as __devinit. However,
>       add_memory() is usually called only after bootup. 
>       I suppose it may be redundant. But, I'm not sure about powerpc.
>       So, I keep it. (But, __meminit is better than __devinit at least.)

My thoughts when originally designing the API were that the architecture
may be the only bit that actually knows where the memory _is_.  So, we
shouldn't involve the generic code in figuring this out.

You can see the result of this in the next patch because there is a new
function introduced to hide the arch-specific node lookup.  If that was
simply done in the already arch-specific add_memory() function, then you
wouldn't need arch_nid_probe() and its related #ifdefs at all.

-- Dave

