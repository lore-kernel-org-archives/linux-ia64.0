From: Andrew Morton <akpm@osdl.org>
Date: Thu, 09 Mar 2006 12:00:31 +0000
Subject: Re: [PATCH: 003/017](RFC) Memory hotplug for new nodes v.3.(get
Message-Id: <20060309040031.2be49ec2.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060308212646.0028.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20060308212646.0028.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: tony.luck@intel.com, ak@suse.de, jschopp@austin.ibm.com, haveblue@us.ibm.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Yasunori Goto <y-goto@jp.fujitsu.com> wrote:
>
> When CONFIG_NUMA && CONFIG_ARCH_MEMORY_PROBE, nid should be defined
>  before calling add_memory_node(nid, start, size).
> 
>  Each arch , which supports CONFIG_NUMA && ARCH_MEMORY_PROBE, should
>  define arch_nid_probe(paddr);
> 
>  Powerpc has nice function. X86_64 has not.....

This patch uses an odd mixture of __devinit and <nothing-at-all> in
arch/x86_64/mm/init.c.  I guess it should be using __meminit
throughout.
