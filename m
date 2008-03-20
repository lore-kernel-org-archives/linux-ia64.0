From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 20 Mar 2008 02:40:25 +0000
Subject: Re: [PATCH 6/8] ptrace: arch_ptrace -ENOSYS return
Message-Id: <alpine.LFD.1.00.0803191935080.3020@woody.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080319211714.8B14226F995@magilla.localdomain> <20080319212024.EA03126F995@magilla.localdomain>
In-Reply-To: <20080319212024.EA03126F995@magilla.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Roland McGrath <roland@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, David Miller <davem@davemloft.net>, sparclinux@vger.kernel.org, Paul Mackerras <paulus@samba.org>, linuxppc-dev@ozlabs.org, Richard Henderson <rth@twiddle.net>, tony.luck@intel.com, linux-ia64@vger.kernel.org



On Wed, 19 Mar 2008, Roland McGrath wrote:
>
> The arch_ptrace and compat_arch_ptrace functions can now return
> -ENOSYS for requests they do not actually implement in arch
> code.

Hmm.. I see the whole series, and I see this patch, but I think it adds 
new code and new complexity, and I don't really see *why*.

So I'm obviously not going to apply it outside the merge window anyway, 
but even for later I'd really like to know what you're building up 
towards, because without understanding the upsides it just feels like it 
adds ugly code and unnecessary infrastructure without any real point to 
it.

And I have to say, I really hate that

		ret = arch_ptrace(child, request, addr, data);
		if (ret = -ENOSYS && !forced_successful_syscall_return())
			ret = ptrace_request(child, request, addr, data);

thing. Instead of doing it that ugly way (return value and a special 
per-arch forced_successful_syscall_return() thing), this really smells 
like you just want to change the calling conventions for "arch_ptrace()" 
instead.

Wouldn't it be nicer to just let "arch_ptrace()" return a flag saying 
whether it handled things or not?

			Linus
