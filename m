From: Petr Tesarik <ptesarik@suse.cz>
Date: Wed, 29 Jun 2011 09:05:59 +0000
Subject: Re: [PATCH 00/10] Enhance /dev/mem to allow read/write of arbitrary physical addresses
Message-Id: <201106291106.00070.ptesarik@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <201106171038.25988.ptesarik@suse.cz>
	<20110617093032.GA19235@elte.hu>
In-Reply-To: <20110617093032.GA19235@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: linux-arm-kernel@lists.infradead.org

Dne Pá 17. června 2011 11:30:32 Ingo Molnar napsal(a):
> * Petr Tesarik <ptesarik@suse.cz> wrote:
> > This patch series enhances /dev/mem, so that read and write is
> > possible at any address. The patchset includes actual
> > implementation for x86.
> 
> This series lacks a description of why this is desired.
>[...]
> 
> Are you aware of any legitimate usecases?

Looking back at the mail tread, I'd say there are people who have legitimate 
usecases. However, this may not be the most important question. At the moment, 
the /dev/mem interface is broken (it doesn't implement the specification 
correctly), and my patchset fixes it.

If there are no technical objections, I'd like to ask for an Acked-by from all 
involved people.

@Ingo: you can also send a patchset that rips off the /dev/mem driver 
completely if you believe that would get through. I'm completely fine with 
that, because then the /dev/crash driver will no longer be a semi-broken re-
implementation of an existing in-kernel driver, so I'll be able to post it as 
a new driver.

But please make a decision either way.

Petr Tesarik
