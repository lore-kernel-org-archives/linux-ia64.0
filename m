From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Thu, 11 May 2023 15:17:29 +0000
Subject: Re: [RFC PATCH v2] fs/xattr: add *at family syscalls
Message-Id: <CAMuHMdVa69s3g0z6qgayzNx=jT6Ko2RNeZehru0SbzYH8VwkfQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230511150802.737477-1-cgzones@googlemail.com>
In-Reply-To: <20230511150802.737477-1-cgzones@googlemail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: =?UTF-8?Q?Christian_G=C3=B6ttsche?= <cgzones@googlemail.com>
Cc: x86@kernel.org, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-fsdevel@vger.kernel.org, audit@vger.kernel.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, linux-security-module@vger.kernel.org, selinux@vger.kernel.org, Nhat Pham <nphamcs@gmail.com>, Andrew Morton <akpm@linux-foundation.org>

Hi Christian,

On Thu, May 11, 2023 at 5:10 PM Christian Göttsche
<cgzones@googlemail.com> wrote:
> Add the four syscalls setxattrat(), getxattrat(), listxattrat() and
> removexattrat().  Those can be used to operate on extended attributes,
> especially security related ones, either relative to a pinned directory
> or on a file descriptor without read access, avoiding a
> /proc/<pid>/fd/<fd> detour, requiring a mounted procfs.
>
> One use case will be setfiles(8) setting SELinux file contexts
> ("security.selinux") without race conditions.
>
> Add XATTR flags to the private namespace of AT_* flags.
>
> Use the do_{name}at() pattern from fs/open.c.
>
> Use a single flag parameter for extended attribute flags (currently
> XATTR_CREATE and XATTR_REPLACE) and *at() flags to not exceed six
> syscall arguments in setxattrat().
>
> Previous approach ("f*xattr: allow O_PATH descriptors"): https://lore.kernel.org/all/20220607153139.35588-1-cgzones@googlemail.com/
> v1 discussion: https://lore.kernel.org/all/20220830152858.14866-2-cgzones@googlemail.com/
>
> Signed-off-by: Christian Göttsche <cgzones@googlemail.com>

Thanks for your patch!

The syscall numbers conflict with those used in "[PATCH] cachestat:
wire up cachestat for other architectures", so this needs some
synchronization.
https://lore.kernel.org/linux-sh/20230510195806.2902878-1-nphamcs@gmail.com

>  arch/m68k/kernel/syscalls/syscall.tbl       |   4 +

For m68k:
Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
