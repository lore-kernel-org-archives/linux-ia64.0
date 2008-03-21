From: Christoph Hellwig <hch@infradead.org>
Date: Fri, 21 Mar 2008 14:07:08 +0000
Subject: Re: [PATCH 6/8] ptrace: arch_ptrace -ENOSYS return
Message-Id: <20080321140708.GA30540@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080319211714.8B14226F995@magilla.localdomain> <20080319212024.EA03126F995@magilla.localdomain> <alpine.LFD.1.00.0803191935080.3020@woody.linux-foundation.org> <20080320081658.0B23826F995@magilla.localdomain> <alpine.LFD.1.00.0803211441180.3781@apollo.tec.linutronix.de>
In-Reply-To: <alpine.LFD.1.00.0803211441180.3781@apollo.tec.linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Roland McGrath <roland@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>, sparclinux@vger.kernel.org, Paul Mackerras <paulus@samba.org>, linuxppc-dev@ozlabs.org, Richard Henderson <rth@twiddle.net>, tony.luck@intel.com, linux-ia64@vger.kernel.org

On Fri, Mar 21, 2008 at 02:50:01PM +0100, Thomas Gleixner wrote:
> What about adding a CONFIG_ARCH_HAS_PTRACE2, which is set by the archs
> which are converted. For those which are not you add a fallback
> implementation:

Bah.  Folks, we're talking about adding a single new argument to a
single function implemented by our 24 architectures.  This is a trivial
almost scriptable conversion.

