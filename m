From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 02 Mar 2001 15:51:55 +0000
Subject: Re: [Linux-ia64] CONFIG_IA64_L1_CACHE_SHIFT
Message-Id: <marc-linux-ia64-105590693005242@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005236@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005236@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 02 Mar 2001 00:18:48 +0100, Jes Sorensen <jes@linuxcare.com> said:

>>>>> "David" = David Mosberger <davidm@hpl.hp.com> writes:
>>>>> On 01 Mar 2001 20:29:28 +0100, Jes Sorensen <jes@linuxcare.com> said:
  Jes> in the config file? We already have SMP_CACHE_BYTES and
  Jes> L1_CACHE bytes for all architectures, it doesn't make a whole
  Jes> lot of sense to me ot invent yet another alignment rule.

  David> $ fgrep CONFIG_IA64_L1 include/asm-ia64/cache.h #define
  David> L1_CACHE_SHIFT CONFIG_IA64_L1_CACHE_SHIFT

  Jes> Hmmm ok

  Jes> It just seemed weird to have it in the config.in
  Jes> file.

Why?  The cache line size is not defined by the architecture (only the
_minimum_ size is architected at 32 bytes), so it may well vary with
future chips.  Also, on some platforms it's beneficial to align to a
bigger size (e.g., SN1), even if the L1 cache line size is the same.

  Jes> Btw. shouldn't the acpi code use SMP_CACHE_BYTES for alignment?
  Jes> It doesn't buy you a whole lot to align on L1 cache boundaries
  Jes> if you're trying to be SMP aware - or is it rather a DMA vs CPU
  Jes> alignment issue?

I don't know.  Not to hurt any feelings, but the ACPI code is a
monstrous piece of software that strikes me as being very poorly
integrated into the Linux kernel.  It seems to redo everything on its
own and does so often more poorly than if it were to use the existing
facilities.  Case in point: it defines its own unaligned access macros
in acmacros.h even though such a facility already is provided in
<asm/unaligned.h>.  Of course, the stuff provided in <asm/unaligned.h>
does the Right Thing, unlike the macros defined in acmacros.h.  Sigh.

My suspicion is that the acpi code is also needlessly complex.  The
ACPI spec obviously doesn't help things (must be the worst spec ever
written), but I think the whole situation is not unlike USB: a poor
spec is likely to lead to a poor implementation, but that doesn't mean
it can't be implemented cleanly.  The question is of course whether
someone cares enough to attempt to either clean up the existing
implementation or re-implement the entire thing from scratch.

	--david

