From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 20 Mar 2008 07:40:05 +0000
Subject: Re: [PATCH 6/8] ptrace: arch_ptrace -ENOSYS return
Message-Id: <20080320074005.GB19969@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080319211714.8B14226F995@magilla.localdomain> <20080319212024.EA03126F995@magilla.localdomain> <alpine.LFD.1.00.0803191935080.3020@woody.linux-foundation.org>
In-Reply-To: <alpine.LFD.1.00.0803191935080.3020@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Roland McGrath <roland@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, David Miller <davem@davemloft.net>, sparclinux@vger.kernel.org, Paul Mackerras <paulus@samba.org>, linuxppc-dev@ozlabs.org, Richard Henderson <rth@twiddle.net>, tony.luck@intel.com, linux-ia64@vger.kernel.org

On Wed, Mar 19, 2008 at 07:40:25PM -0700, Linus Torvalds wrote:
> 
> And I have to say, I really hate that
> 
> 		ret = arch_ptrace(child, request, addr, data);
> 		if (ret = -ENOSYS && !forced_successful_syscall_return())
> 			ret = ptrace_request(child, request, addr, data);
> 
> thing. Instead of doing it that ugly way (return value and a special 
> per-arch forced_successful_syscall_return() thing), this really smells 
> like you just want to change the calling conventions for "arch_ptrace()" 
> instead.
> 
> Wouldn't it be nicer to just let "arch_ptrace()" return a flag saying 
> whether it handled things or not?

I think the easiest and cleanest would be to just drop this whole
series.  There's no inherent advantage of

	ret = -ENOSYS;

in the arch_ptrace default case over

	ret = ptrace_request(...);

