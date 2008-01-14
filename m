From: "Luming Yu" <luming.yu@gmail.com>
Date: Mon, 14 Jan 2008 09:24:21 +0000
Subject: Re: [RFC PATCH] enabling kernel lock validator for ia64
Message-Id: <3877989d0801140124md783530m9e688459877bb63c@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

Thanks for pointing out the problems, I will update patch accordingly.

>
> Next on your TODO list was:
> >  1.MAX_LOCKDEP_KEYS too low! (*due to ia64 64K percpu data size limitation*)
>
> How much extra per-cpu memory (roughly) do we need.  Would it be enough to
> jump from 64K to the next supported page size (256K), or the one after (1MB).
> It should be relatively simple to make the per-cpu page size larger for the
> lockdep config.  Or do we need *MUCH* more per-cpu memory for this?

the default MAX_LOCKDEP_KEYS_BITS 11 will lead to the demand of 1M
per cpu memory.(.data.percpu [0000000004980000 -> 00000000049e7917])

Thanks,
Luming
