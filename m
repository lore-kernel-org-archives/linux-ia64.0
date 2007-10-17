From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Wed, 17 Oct 2007 10:49:37 +0000
Subject: Re: [RFC patch] fallback to "no irq" hack for case of no pnp_irq
Message-Id: <20071017114937.0a646f27@the-village.bc.nu>
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0710161950n3d255330lf55e190dde628277@mail.gmail.com>
In-Reply-To: <3877989d0710161950n3d255330lf55e190dde628277@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Luming Yu <luming.yu@gmail.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

> Signed-off-by: Yu Luming <luming.yu@intel.com>
> 
>  8250_pnp.c |    3 +++
>  1 files changed, 3 insertions(+)

Should really fix pnp_irq() to use zero to mean none as the kernel
intends. If that causes other complications then this hack will do for
now I guess.

Alan
