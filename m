From: Jesse Barnes <jbarnes@sgi.com>
Date: Thu, 08 May 2003 16:07:14 +0000
Subject: Re: [Linux-ia64] Re: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705681@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, May 07, 2003 at 09:59:41PM -0700, David Mosberger wrote:
>   Keith> GPREL22, LTOFF22, LTOFF_FPTR22, PCREL21B, PCREL60B,
>   Keith> SEGREL64LSB are not a problem, they are already PIC.
>   Keith> DIR32LSB, DIR64LSB, FPTR64LSB are easy to adjust.  IMM64 is
>   Keith> the only messy bit of code, lots of shifts.  Even IMM64 is
>   Keith> not that hard to do in PIC asm.
> 
> Remember, we already have the in-kernel module loader, which has to
> deal with "ld -r" modules.  I'd have preferred if those had been
> shared objects, too, but apparently the toolchains on some other
> platforms is sufficiently broken that this wasn't a feasible option
> (not for 2.6, anyhow).

So simply linking with 'ld -q' wouldn't be sufficient?  Doesn't that
produce a binary that will boot w/o elilo changes, but can also be
relocated?

Thanks,
Jesse

