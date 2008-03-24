From: Paul Mackerras <paulus@samba.org>
Date: Mon, 24 Mar 2008 07:55:41 +0000
Subject: Re: [PATCH 4/8] powerpc ptrace: forced_successful_syscall_return()
Message-Id: <18407.24189.707297.767237@cargo.ozlabs.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080319211714.8B14226F995@magilla.localdomain>
	<20080319211936.28E8B26F9A7@magilla.localdomain>
In-Reply-To: <20080319211936.28E8B26F9A7@magilla.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Roland McGrath <roland@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, David Miller <davem@davemloft.net>, sparclinux@vger.kernel.org, linuxppc-dev@ozlabs.org, Richard Henderson <rth@twiddle.net>, tony.luck@intel.com, linux-ia64@vger.kernel.org

Roland McGrath writes:

> Define the forced_successful_syscall_return() macro to
> pair with our force_successful_syscall_return() definition.
> 
> Signed-off-by: Roland McGrath <roland@redhat.com>

Looks OK to me, but what's it useful for?

Paul.
