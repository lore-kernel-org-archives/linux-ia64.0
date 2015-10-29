From: =?UTF-8?Q?=C3=89meric_MASCHINO?= <emeric.maschino@gmail.com>
Date: Thu, 29 Oct 2015 13:47:02 +0000
Subject: Re: [GIT PULL] Add kcmp() syscall for ia64
Message-Id: <CAA9xbM4xkZQQdu9sN6mxR12TedOWzfQucU29LC-NirOcLsrEdg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5631485d20491d50e7@agluck-desk.sc.intel.com>
In-Reply-To: <5631485d20491d50e7@agluck-desk.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: linux-ia64@vger.kernel.org

Thanks.

Tony, this reminds me a comment that you made some time ago, when I
sent to the linux-ia64 patches to add accept4() syscall that was
equally forgotten in it's time.

Here's what you were saying to me by mail on September 1st, 2012:

"Hmmm.  I looked into this a bit further - and found that I hadn't
seen a warning about the missing accept4() system call from
scripts/checksyscalls.sh because it just compares against the x86_32
list - and accept4() isn't there."

Hence my question: Was it also the case for kcmp() syscall? If yes,
what could be done to ensure that such miss at adding syscall can be
avoided in the future?

     Émeric

2015-10-28 23:12 GMT+01:00 Luck, Tony <tony.luck@intel.com>:
> The following changes since commit 32b88194f71d6ae7768a29f87fbba454728273ee:
>
>   Linux 4.3-rc7 (2015-10-25 10:39:47 +0900)
>
> are available in the git repository at:
>
>   git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-syscalls
>
> for you to fetch changes up to d305c4773458fdd6ff9c52bfdea8c67fbd3b2072:
>
>   [IA64] Wire up kcmp syscall (2015-10-28 14:22:59 -0700)
>
> ----------------------------------------------------------------
> Missed adding the kcmp() syscall a long time ago. Now it seems
> that it is essential to build systemd.
>
> ----------------------------------------------------------------
> Émeric MASCHINO (1):
>       [IA64] Wire up kcmp syscall
>
>  arch/ia64/include/asm/unistd.h      | 2 +-
>  arch/ia64/include/uapi/asm/unistd.h | 1 +
>  arch/ia64/kernel/entry.S            | 1 +
>  3 files changed, 3 insertions(+), 1 deletion(-)
