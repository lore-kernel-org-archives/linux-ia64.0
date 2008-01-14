From: Christoph Hellwig <hch@infradead.org>
Date: Mon, 14 Jan 2008 07:41:51 +0000
Subject: Re: [PATCH] Fix kprobes on ia64
Message-Id: <20080114074151.GA15431@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080114022423.GH18741@parisc-linux.org>
In-Reply-To: <20080114022423.GH18741@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>

On Sun, Jan 13, 2008 at 07:24:24PM -0700, Matthew Wilcox wrote:
> If CONFIG_KPROBES is set, we get the error during build:
> 
> kernel/kprobes.c:1057: error: __ksymtab_jprobe_return causes a section
> type conflict
> 
> This is because ia64 defines a static inline jprobe_return which kprobes
> attempts to EXPORT_SYMBOL.

Given that jprobe_return is defined in the arch-specific kprobes.c file
it would be better to export it there instead of in kernel/kprobe.c, or
in case of ia64 not export it at all.

