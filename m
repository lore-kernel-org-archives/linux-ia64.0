From: Jes Sorensen <jes@sgi.com>
Date: Thu, 16 Mar 2006 11:02:34 +0000
Subject: Re: [PATCH] Fix percpu interrupt allocation in mmtimer code
Message-Id: <yq0oe06veid.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060315143906.GE29195@sgi.com>
In-Reply-To: <20060315143906.GE29195@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Dimitri" = Dimitri Sivanich <sivanich@sgi.com> writes:

Dimitri> The timer interrupt in the mmtimer code needs to be allocated
Dimitri> as a percpu interrupt for acceptable performance on larger
Dimitri> systems.

Dimitri> The code needs to be updated to set this up properly, as the
Dimitri> SA_PERCPU_IRQ flag to request_interrupt is not supported.

Dimitri> +EXPORT_SYMBOL(register_percpu_irq);

Hi Dimitri,

EXPORT_SYMBOL_GPL() please.

Dimitri> +static irqreturn_t mmtimer_interrupt(int irq, void *dev_id, struct pt_regs *regs);
Dimitri> +

The prototype needs to go into a header file, it shouldn't be declared
in mmtimer.c. Also please make sure it doesn't exceed the 80 column
limit.

Cheers,
Jes
