From: Grant Grundler <grundler@cup.hp.com>
Date: Tue, 23 Apr 2002 21:11:37 +0000
Subject: Re: [Linux-ia64] Re: PCI DAC routines for SN
Message-Id: <marc-linux-ia64-105590701905512@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905493@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905493@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jesse Barnes wrote:
> He was the one that implemented it I thought.  His assertion was that
> since most chipsets don't handle 64 bit coherent allocations well, the
> consistent interface should be forced to return a 32 bit address (is
> that right Dave?).

Right - HP recently changed ZX1 support based on the same assertion.
And for the drivers I'm aware of (eg tg3, sym53c8xx), Dave is right.

...
> otherwise I'd like to leave it up to the platform
> (i.e. ia64/sn could return a 64 bit address and sparc64 could do 32).

This is not feasible. The driver/device will use/support the same number
of address bits regardless of architecture. If the architecture provides
fewer bits than the driver/device supports, no problem obviously.

I'm curious to see what happens with the pci_dac_alloc_consistent() idea.

grant

