From: Christoph Lameter <christoph@lameter.com>
Date: Wed, 30 Mar 2005 18:13:49 +0000
Subject: Re: API changes to the slab allocator for NUMA memory allocation
Message-Id: <Pine.LNX.4.58.0503301013060.15596@server.graphe.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050315204110.6664771d.akpm@osdl.org> <42387C2E.4040106@colorfullife.com>
 <273220000.1110999247@[10.10.2.4]> <4238845E.5060304@colorfullife.com>
 <Pine.LNX.4.58.0503292126050.32140@server.graphe.net> <424A3FA0.9030403@colorfullife.com>
 <Pine.LNX.4.58.0503300748320.12816@server.graphe.net> <424AE7F7.3080508@colorfullife.com>
In-Reply-To: <424AE7F7.3080508@colorfullife.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Manfred Spraul <manfred@colorfullife.com>
Cc: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, shai@scalex86.org

On Wed, 30 Mar 2005, Manfred Spraul wrote:

> Correct, I was thinking about the NUMA case.
> You've decided to add one register load to every call of kmalloc. On
> i386, kmalloc_node() is a 24-byte function. I'd bet that adding the node
> parameter to every call of kmalloc causes a .text increase larger than
> 240 bytes. And I have not yet considered that you have increased the
> number of conditional branches in every kmalloc(32,GFP_KERNEL) call by
> 33%, i.e. from 3 to 4 conditional branch instructions.
> I'd add an explicit kmalloc_node function. Attached is a prototype
> patch. You'd have to reintroduce the flags field to
> kmem_cache_alloc_node() and update kmalloc_node.
> The patch was manually edited, I hope it applies to a recent tree ;-)
>
> What do you think?

Looks fine to me.
