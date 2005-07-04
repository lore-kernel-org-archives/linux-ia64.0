From: Christoph Hellwig <hch@infradead.org>
Date: Mon, 04 Jul 2005 15:09:33 +0000
Subject: Re: Fast Syscalls and Virtualised Linux on Linux
Message-Id: <20050704150933.GA4102@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <17090.8605.481641.322881@wombat.chubb.wattle.id.au>
In-Reply-To: <17090.8605.481641.322881@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jul 01, 2005 at 09:05:36AM +1000, Peter Chubb wrote:
> In the clone2() commentary there's:
> 
> 	/*
> 	 * clone2() is special: the child cannot execute br.ret right
> 	 * after the system call returns, because it starts out
> 	 * executing on an empty stack.  Because of this, we can't use
> 	 * the new (lightweight) syscall convention here.  Instead, we
> 	 * just fall back on always using "break".
> 	 *
> 	 * Furthermore, since the child starts with an empty stack, we
> 	 * need to avoid unwinding past invalid memory.  To that end,
> 	 * we'll pretend now that __clone2() is the end of the
> 	 * call-chain.  This is wrong for the parent, but only until
> 	 * it returns from clone2() but it's better than the
> 	 * alternative.
> 	 */

I might be missing something, so please help me a little more.  If you
look at x86 they always provider a vdso, for hardware recent enough
yhey use sysenter, else they do the same old int 0x80 an old libc would
do.  Now in the ia64 vdso couldn't you do a syscall similar enough to
the old one, just with the fixups inline you'd want the patches libc
for?

