From: Frank Scheiner <frank.scheiner@web.de>
Date: Sat, 27 May 2023 18:34:50 +0000
Subject: Re: Boot regression in Linux v6.4-rc3
Message-Id: <b2b47c19-d527-fbd2-1666-801f173b6174@web.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <abb1166d-27a9-fbae-59cd-841480fba78a@web.de>
In-Reply-To: <abb1166d-27a9-fbae-59cd-841480fba78a@web.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

On 27.05.23 19:08, Linus Torvalds wrote:
> Anyway, the WARN_ON() is likely related, but the bug is clearly an
> unexpected page fault in __copy_user() when called by load_module().
>
> The ia64 oops output is nasty, presumably because ia64 aggressively
> inlines things. It would help a lot if you enabled debug info (maybe
> you already do?)

I believe it is enabled - I have at least CONFIG_DEBUG_KERNEL=y and
CONFIG_DEBUG_INFO=y - my kernel config is on [1] for reference.

[1]: https://pastebin.com/HRQtZ9vb

> and then run the oops through
> ./scripts/decode_stacktrace.sh which will figure out line numbers,
> inlining etc.
>
> Because I don't even see why it would call __copy_user() in the first
> place. This is 'finit_module()' that loads the module data from a
> file, not user space.
>
> So I guess it must be the strndup_user() in
>
>          mod->args = strndup_user(uargs, ~0UL >> 1);
>
> but that doesn't look like it should even care about any module
> layout. Plus I would have expected to see strndup_user() in the call
> trace, but whatever.
>
> End result: that ia64 trace is very hard to read, and _maybe_ running
> it through the decode script might give more information about what it
> is that triggers...

Ok, I put the decoded console messages on [2].

[2]: https://pastebin.com/dLYMijfS

Cheers,
Frank
