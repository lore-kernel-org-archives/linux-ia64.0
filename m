From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 17 Feb 2011 17:23:21 +0000
Subject: Re: [PATCH 3/3] ia64: drop custom exception table implementation
Message-Id: <20110217172321.GC17058@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <4D5D631F0200007800032802@vpn.id2.novell.com>
In-Reply-To: <4D5D631F0200007800032802@vpn.id2.novell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jan Beulich <JBeulich@novell.com>
Cc: tony.luck@intel.com, tglx@linutronix.de, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, hpa@zytor.com


* Jan Beulich <JBeulich@novell.com> wrote:

> Now that the common extable implementation can deal with the needs
> ia64 has, drop its custom implementation.
> 
> Signed-off-by: Jan Beulich <jbeulich@novell.com>
> 
> ---
>  arch/ia64/Kconfig               |    1 
>  arch/ia64/include/asm/uaccess.h |    9 ---
>  arch/ia64/mm/extable.c          |   98 ----------------------------------------
>  3 files changed, 4 insertions(+), 104 deletions(-)

Nice generalization of the exception code.

If Tony acks this patch then we can put the 3 patches into a separate -tip branch 
and test it on x86 and push it into -next for ia64 testing. That would be the 
simplest upstream merge route - if that's fine by Tony as well.

Thanks,

	Ingo
