From: Sam Ravnborg <sam@ravnborg.org>
Date: Mon, 14 Jan 2008 06:02:56 +0000
Subject: Re: [PATCH] Fix kprobes on ia64
Message-Id: <20080114060256.GB5187@uranus.ravnborg.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080114022423.GH18741@parisc-linux.org>
In-Reply-To: <20080114022423.GH18741@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>

On Sun, Jan 13, 2008 at 07:24:24PM -0700, Matthew Wilcox wrote:
> 
> If CONFIG_KPROBES is set, we get the error during build:
> 
> kernel/kprobes.c:1057: error: __ksymtab_jprobe_return causes a section
> type conflict
> 
> This is because ia64 defines a static inline jprobe_return which kprobes
> attempts to EXPORT_SYMBOL.

The better fix is to let jprobe_return be a normal function that can be exported.
Then we avoid this arch specific ifdef for the cost of nothing.

	Sam
