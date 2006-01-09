From: Christoph Hellwig <hch@infradead.org>
Date: Mon, 09 Jan 2006 17:25:54 +0000
Subject: Re: [PATCH] ia64: including <asm/signal.h> alone causes compilation errors
Message-Id: <20060109172554.GA3026@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060109171514.GA25096@locomotive.unixthugs.org>
In-Reply-To: <20060109171514.GA25096@locomotive.unixthugs.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jeff Mahoney <jeffm@suse.com>
Cc: linux-ia64@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Jan 09, 2006 at 12:15:14PM -0500, Jeff Mahoney wrote:
> 
>  Including *just* <asm/signal.h> on ia64 will result in a compilation failure,
>  where it will succeed on every other architecture.
> 
>  Every other arch includes <linux/compiler.h> either directly or via
>  <linux/types.h> at the top of <asm-*/signal.h>. ia64 includes
>  <linux/types.h> after including <asm-generic/signal.h>, which causes
>  the __user in <asm-generic/signal.h> to get passed through untouched, causing
>  compilation errors.
> 
>  This patch moves the #include <linux/types.h> up to the beginning of signal.h,
>  as found on every other arch.
> 
>  A specific example of where this behavior is observed is the recent addition
>  of OCFS2. fs/ocfs2/cluster/userdlm.c seems alone in only including
>  <asm/signal.h>, which seems to be perfectly valid.

Generally you should only include <asm/signal.h> via <linux/signal.h>, which gets
<linux/compiler.h> via <linux/spinlock.h>

