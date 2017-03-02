From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 02 Mar 2017 13:07:20 +0000
Subject: Re: [PATCH] uapi: fix another asm/shmbuf.h userspace compilation error
Message-Id: <CAK8P3a1=-Q=gVRyk+PwqxTeTPXa4yrmqWKG7SyZng2d7bcbG=g@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170302004607.GE27132@altlinux.org>
In-Reply-To: <20170302004607.GE27132@altlinux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Dmitry V. Levin" <ldv@altlinux.org>
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, linux-xtensa@linux-xtensa.org, Heiko Carstens <heiko.carstens@de.ibm.com>, David Howells <dhowells@redhat.com>, Max Filippov <jcmvbkbc@gmail.com>, Paul Mackerras <paulus@samba.org>, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, Hans-Christian Egtvedt <egtvedt@samfundet.no>, linux-arch <linux-arch@vger.kernel.org>, linux-s390@vger.kernel.org, linux-am33-list@redhat.com, x86@kernel.org, Ingo Molnar <mingo@redhat.com>, Haavard Skinnemoen <hskinnemoen@gmail.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Chris Zankel <chris@zankel.net>, Tony Luck <tony.luck@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Ralf Baechle <ralf@linux-mips.org>, linux-alpha@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>

On Thu, Mar 2, 2017 at 1:46 AM, Dmitry V. Levin <ldv@altlinux.org> wrote:
> Replace size_t with __kernel_size_t to fix asm/shmbuf.h userspace
> compilation errors like this:
>
> /usr/include/asm-generic/shmbuf.h:28:2: error: unknown type name 'size_t'
>   size_t   shm_segsz; /* size of segment (bytes) */
>
> x32 is the only architecture where sizeof(size_t) is less than
> sizeof(__kernel_size_t), but as the kernel treats shm_segsz field as
> __kernel_size_t anyway, UAPI should follow.  Thanks to little-endiannes
> of x32 and 64-bit alignment of the field following shm_segsz, this
> change doesn't break ABI, and the difference doesn't manifest itself
> easily.
>
> Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>

Acked-by: Arnd Bergmann <arnd@arndb.de>
