From: Matthew Wilcox <willy@debian.org>
Date: Mon, 29 Dec 2003 22:31:33 +0000
Subject: Re: [PATCH] - ia64_ctx.lock deadlock
Message-Id: <marc-linux-ia64-107273711605274@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107253552523782@msgid-missing>
In-Reply-To: <marc-linux-ia64-107253552523782@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, Dec 27, 2003 at 08:27:22AM -0600, Jack Steiner wrote:
> I hit a deadlock involving the ia64_ctx.lock. The lock
> may be taken in interrupt context to process an IPI from smp_flush_tlb_mm.
> 
> Here is a patch:
> -	spin_lock(&ia64_ctx.lock);
> +	spin_lock_irqsave(&ia64_ctx.lock, flags);

Would it be better to use spin_lock_irq() / spin_unlock_irq() here?
It seems to me this function is only called from task context.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
