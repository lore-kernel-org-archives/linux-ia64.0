From: Jes Sorensen <jes@linuxcare.com>
Date: Thu, 01 Mar 2001 23:18:48 +0000
Subject: Re: [Linux-ia64] CONFIG_IA64_L1_CACHE_SHIFT
Message-Id: <marc-linux-ia64-105590693005238@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005236@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005236@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@hpl.hp.com> writes:

>>>>> On 01 Mar 2001 20:29:28 +0100, Jes Sorensen <jes@linuxcare.com> said:
Jes> in the config file? We already have SMP_CACHE_BYTES and L1_CACHE
Jes> bytes for all architectures, it doesn't make a whole lot of sense
Jes> to me ot invent yet another alignment rule.

David> $ fgrep CONFIG_IA64_L1 include/asm-ia64/cache.h #define
David> L1_CACHE_SHIFT CONFIG_IA64_L1_CACHE_SHIFT

Hmmm ok

It just seemed weird to have it in the config.in file. Btw. shouldn't
the acpi code use SMP_CACHE_BYTES for alignment? It doesn't buy you a
whole lot to align on L1 cache boundaries if you're trying to be SMP
aware - or is it rather a DMA vs CPU alignment issue?

Jes

