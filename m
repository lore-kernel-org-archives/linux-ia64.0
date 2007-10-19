From: Christoph Hellwig <hch@infradead.org>
Date: Fri, 19 Oct 2007 20:20:21 +0000
Subject: Re: [PATCH] Simplify ptrace handling
Message-Id: <20071019202021.GA7913@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1192823729.2727.56.camel@elijah.suse.cz>
In-Reply-To: <1192823729.2727.56.camel@elijah.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Oct 19, 2007 at 09:55:29PM +0200, Petr Tesarik wrote:
> Hi,
> 
> with Shaohua Li's patch we can get rid of much of the ugly code in
> arch/ia64/kernel/ptrace.c:
> 
>  - find_thread_for_addr() is no longer needed
>  - most calls to ia64_poke() and ia64_peek() can be converted to
>    simple accesses to the VM
> 
> This patch is incremental with Shaohua Li's fix, so it can't be applied
> until we resolve the only remaining problem (race condition in
> ptrace_stop). I'm only sending it to demonstrate the benefits of that
> patch.

Nice.  With this you should also be able to switch to the generic sys_ptrace
easily, could you add that to your patch?

