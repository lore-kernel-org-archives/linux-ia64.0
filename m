From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 28 Sep 2018 12:09:30 +0000
Subject: Re: [PATCH v2 7/7] ia64: add __IGNORE* entries in asm/unistd.h
Message-Id: <CAK8P3a2E2KJApEcwpJgqs9KHuyr-mzE8Y6F+D1E0akpXt8VK_Q@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1538057720-3392-1-git-send-email-firoz.khan@linaro.org> <1538057720-3392-8-git-send-email-firoz.khan@linaro.org>
In-Reply-To: <1538057720-3392-8-git-send-email-firoz.khan@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Firoz Khan <firoz.khan@linaro.org>
Cc: linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, gregkh <gregkh@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, y2038 Mailman List <y2038@lists.linaro.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Deepa Dinamani <deepa.kernel@gmail.com>, Marcin Juszkiewicz <marcin.juszkiewicz@linaro.org>

On Thu, Sep 27, 2018 at 4:16 PM Firoz Khan <firoz.khan@linaro.org> wrote:
>
> Add __IGNORE* entries for perf_event_open, seccomp, pkey_
> mprotect, pkey_alloc, pkey_free, statx, io_pgetevents and
> rseq in the file asm/unistd.h as it is correct to keep
> __IGNORE* entry in non uapi header asm/unistd.h while uapi/
> asm/unistd.h must hold information only useful for user
> space applications.
>
> Signed-off-by: Firoz Khan <firoz.khan@linaro.org>
> ---

This patch looks wrong: We don't want to ignore the fact that the
syscalls are missing here, we should add them instead. I'd leave
that for a follow-up though, we may want to add further ones that
are currently marked as __IGNORE.

      Arnd
