From: Grant Grundler <iod00d@hp.com>
Date: Fri, 27 May 2005 18:27:00 +0000
Subject: Re: flush_icache_range
Message-Id: <20050527182700.GE7444@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4236D7B5.8050408@bull.net>
In-Reply-To: <4236D7B5.8050408@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, May 27, 2005 at 06:45:19PM +0200, Zoltan Menyhart wrote:
> Anyway, due to the usage of the #ifdef CONFIG_ITANIUM's
> and the way how they are used, I think the current kernel
> does not support mixed Itanium 1 and 2 CPUs.

I'm not sure how the HW could support given the two
use a different system bus (Merced vs Mckinley).

Even if someone made a chipset that could supported it (NumaLink?)
they might ban such configurations to avoid getting
dragged to the lowest common denominator in performance
or have pay obscene amounts to test something few customers
will actually use.

grant
