From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Thu, 30 Jun 2005 23:05:36 +0000
Subject: Re: Fast Syscalls and Virtualised Linux on Linux
Message-Id: <17092.31424.642521.152067@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <17090.8605.481641.322881@wombat.chubb.wattle.id.au>
In-Reply-To: <17090.8605.481641.322881@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Christoph" = Christoph Hellwig <hch@infradead.org> writes:

Christoph> On Wed, Jun 29, 2005 at 02:20:45PM +1000, Peter Chubb
Christoph> wrote:
>> One approach might be to redefine __BREAK_SYSCALL for the guest OS.
>> That'd require a specially compiled glibc and kernel, and possibly
>> other executables.
>> 
>> Does anyone have a better idea?

Christoph> Make sure glibc is always doing syscalls via the vdso (and
Christoph> that the kernel actually support this ;-)) Then the guest

It doesn't, that's the problem (otherwise it's easy).

Problem areas are:
	sys_sigreturn
	sys_clone2
	sys_syscall
	sys_vfork



In the clone2() commentary there's:

	/*
	 * clone2() is special: the child cannot execute br.ret right
	 * after the system call returns, because it starts out
	 * executing on an empty stack.  Because of this, we can't use
	 * the new (lightweight) syscall convention here.  Instead, we
	 * just fall back on always using "break".
	 *
	 * Furthermore, since the child starts with an empty stack, we
	 * need to avoid unwinding past invalid memory.  To that end,
	 * we'll pretend now that __clone2() is the end of the
	 * call-chain.  This is wrong for the parent, but only until
	 * it returns from clone2() but it's better than the
	 * alternative.
	 */


-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
