From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 10 May 2022 22:33:09 +0000
Subject: Re: [PATCH 12/22] ia64: cleanup remove_siblinginfo()
Message-Id: <20220510153309.b721988023b4d0e1e727f0cb@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220510154750.212913-1-yury.norov@gmail.com>
        <20220510154750.212913-13-yury.norov@gmail.com>
In-Reply-To: <20220510154750.212913-13-yury.norov@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yury Norov <yury.norov@gmail.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>, David Laight <David.Laight@ACULAB.COM>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Joe Perches <joe@perches.com>, Julia Lawall <Julia.Lawall@inria.fr>, =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>, Nicholas Piggin <npiggin@gmail.com>, Nicolas Palix <nicolas.palix@imag.fr>, Peter Zijlstra <peterz@infradead.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Matti Vaittinen <Matti.Vaittinen@fi.rohmeurope.com>, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, Valentin Schneider <vschneid@redhat.com>, linux-ia64@vger.kernel.org

On Tue, 10 May 2022 08:47:40 -0700 Yury Norov <yury.norov@gmail.com> wrote:

> remove_siblinginfo() initialises variable 'last', but never uses it.
> Drop unneeded code.

ack.  I'll assume you'll be merging this up.
