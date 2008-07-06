From: Ingo Molnar <mingo@elte.hu>
Date: Sun, 06 Jul 2008 06:13:11 +0000
Subject: Re: the printk problem
Message-Id: <20080706061311.GA23606@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080704104634.GA31634@digi.com> <20080704111540.ddffd241.akpm@linux-foundation.org> <alpine.LFD.1.10.0807041147450.2815@woody.linux-foundation.org> <alpine.LFD.1.10.0807041250220.2815@woody.linux-foundation.org> <1215212420.8970.8.camel@pasglop> <alpine.LFD.1.10.0807041622270.2815@woody.linux-foundation.org> <alpine.LFD.1.10.0807051523180.2847@woody.linux-foundation.org> <20080706052741.GA18928@elte.hu> <alpine.LFD.1.10.0807052232530.3016@woody.linux-foundation.org> <20080706055317.GA4212@elte.hu>
In-Reply-To: <20080706055317.GA4212@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@ozlabs.org, linux-ia64@vger.kernel.org, parisc-linux@parisc-linux.org, "David S. Miller" <davem@davemloft.net>, Peter Anvin <hpa@zytor.com>, Arjan van de Ven <arjan@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>


* Ingo Molnar <mingo@elte.hu> wrote:

> yeah, agreed, combined it's not an x86 topic anymore.
> 
> [ There's some lkml trouble so i've missed the earlier patch. I'm not 
>   sure the email problem is on my side, see how incomplete the 
>   discussion is on lkml.org as well:
> 
>      http://lkml.org/lkml/2008/6/25/170   ]
> 
> Anyway, i have have added this second patch of yours to 
> tip/core/printk and moved your first patch over to that topic (which 
> relies on it).

ah, i found the reason - it started out on linux-ia64 originally then 
moved over to lkml - so only half of the discussion was visible there. 
And linux-ia64 is one of the few vger lists i'm not subscribed to 
apparently. (there's no vger-please-give-me-all-emails list - making the 
following of Linux development even harder)

	Ingo
