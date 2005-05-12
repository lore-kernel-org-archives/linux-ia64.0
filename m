From: Grant Grundler <iod00d@hp.com>
Date: Thu, 12 May 2005 21:58:15 +0000
Subject: Re: Redirectable IRQs
Message-Id: <20050512215815.GC15608@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <OFC99CCFB1.3123C49E-ON07256FFF.00687D83-07256FFF.0069CEAC@us-phx1.az05.bull.com>
In-Reply-To: <OFC99CCFB1.3123C49E-ON07256FFF.00687D83-07256FFF.0069CEAC@us-phx1.az05.bull.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, May 12, 2005 at 01:37:46PM -0700, Michael.Meduna@Bull.com wrote:
> Thank you for the reply.
> I forgot to mention that this is an Intel ia64 platform.

Yes, Intel implements XTP - but that doesn't mean you have to use it.
You can bind each IRQ source to a single processor.

grant
