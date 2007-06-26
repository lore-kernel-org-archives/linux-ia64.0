From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 26 Jun 2007 02:00:57 +0000
Subject: Re: [PATCH 3/3] Make jprobes a little safer for users
Message-Id: <20070625190057.c8dcb110.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <78935473b1f70c863ab0be7d6cf4bcb04922b20b.1182822366.git.michael@ellerman.id.au>
	<7a070581b2fe53ea65216e86c86abc4f40464341.1182822366.git.michael@ellerman.id.au>
In-Reply-To: <7a070581b2fe53ea65216e86c86abc4f40464341.1182822366.git.michael@ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michael Ellerman <michael@ellerman.id.au>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org, Christoph Hellwig <hch@lst.de>, anil.s.keshavamurthy@intel.com, ananth@in.ibm.com

On Tue, 26 Jun 2007 11:48:51 +1000 (EST) Michael Ellerman <michael@ellerman.id.au> wrote:

> I realise jprobes are a razor-blades-included type of interface, but
> that doesn't mean we can't try and make them safer to use. This guy I
> know once wrote code like this:
> 
> struct jprobe jp = { .kp.symbol_name = "foo", .entry = "jprobe_foo" };
> 
> And then his kernel exploded. Oops.
> 
> This patch adds an arch hook, arch_deref_entry_point() (I don't like it either)
> which takes the void * in a struct jprobe, and gives back the text address
> that it represents.
> 
> We can then use that in register_jprobe() to check that the entry point
> we're passed is actually in the kernel text, rather than just some random
> value.
> 
> Signed-off-by: Michael Ellerman <michael@ellerman.id.au>
> ---
>  arch/ia64/kernel/kprobes.c    |    7 ++++++-
>  arch/powerpc/kernel/kprobes.c |   11 ++++++++---
>  kernel/kprobes.c              |    9 +++++++++

We're missing a declaration of arch_deref_entry_point() in some header file?

