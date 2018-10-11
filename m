From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 11 Oct 2018 07:24:43 +0000
Subject: Re: [PATCH v3 7/7] ia64: wire up system calls
Message-Id: <CAK8P3a3OS-aKFrb5g1i00-+G1+uZqEkH0C1FX08tTx=-89-hfQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1539231895-4118-1-git-send-email-firoz.khan@linaro.org> <1539231895-4118-8-git-send-email-firoz.khan@linaro.org>
In-Reply-To: <1539231895-4118-8-git-send-email-firoz.khan@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Firoz Khan <firoz.khan@linaro.org>
Cc: linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, gregkh <gregkh@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, y2038 Mailman List <y2038@lists.linaro.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Deepa Dinamani <deepa.kernel@gmail.com>, Marcin Juszkiewicz <marcin.juszkiewicz@linaro.org>

On Thu, Oct 11, 2018 at 6:26 AM Firoz Khan <firoz.khan@linaro.org> wrote:
>
> wire up perf_event_open, seccomp, pkey_mprotect, pkey_alloc,
> pkey_free, statx, io_pgetevents and rseq system calls
>
> This require an architecture specific implementation as it not
> present now.
>
> Signed-off-by: Firoz Khan <firoz.khan@linaro.org>
> ---
>  arch/ia64/kernel/syscalls/syscall.tbl | 16 ++++++++++++++++
>  1 file changed, 16 insertions(+)
>
> diff --git a/arch/ia64/kernel/syscalls/syscall.tbl b/arch/ia64/kernel/syscalls/syscall.tbl
> index 6b64f60..1f42b60 100644
> --- a/arch/ia64/kernel/syscalls/syscall.tbl
> +++ b/arch/ia64/kernel/syscalls/syscall.tbl
> @@ -335,3 +335,19 @@
>  323     common  copy_file_range                 sys_copy_file_range
>  324     common  preadv2                         sys_preadv2
>  325     common  pwritev2                        sys_pwritev2
> +# perf_event_open requires an architecture specific implementation
> +326    common  perf_event_open                 sys_perf_event_open
> +# seccomp requires an architecture specific implementation
> +327    common  seccomp                         sys_seccomp

I don't think that's correct for these two. perf_event_open() of
course requires 'perf' support that ia64 does not have, but
at least seccomp should just work.

> +# pkey_mprotect requires an architecture specific implementation
> +328    common  pkey_mprotect                   sys_pkey_mprotect
> +# pkey_alloc requires an architecture specific implementation
> +329    common  pkey_alloc                      sys_pkey_alloc
> +# pkey_free requires an architecture specific implementation
> +330    common  pkey_free                       sys_pkey_free

One comment for all pkey calls would be sufficient. More importantly
it requires hardware support that ia64 does not have AFAICT.

> +# statx requires an architecture specific implementation
> +331    common  statx                           sys_statx
> +# io_pgetevents requires an architecture specific implementation
> +332    common  io_pgetevents                   sys_io_pgetevents

It certainly does not require any support from the architecture for these.

> +# rseq requires an architecture specific implementation
> +333    common  rseq                            sys_rseq

Maybe leave rseq and pkey_* commented out so we reserve
the number but don't add it for real? Maybe the ia64 maintainers
have a preference.

As asm-generic maintainer, I'd like to have the various asm/unistd.h
headers be as similar as possible and at least reserve all the
numbers even if we don't need the calls on a given architecture.

       Arnd
