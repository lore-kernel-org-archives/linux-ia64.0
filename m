From: Matt Turner <mattst88@gmail.com>
Date: Wed, 04 May 2011 18:13:29 +0000
Subject: Re: [PATCH] atomic: add *_dec_not_zero
Message-Id: <BANLkTinWa9E1_iLWyqAF+G8Qag=YK2T98A@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1304458235-28473-1-git-send-email-sven@narfation.org>
In-Reply-To: <1304458235-28473-1-git-send-email-sven@narfation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Sven Eckelmann <sven@narfation.org>
Cc: linux-kernel@vger.kernel.org, David Howells <dhowells@redhat.com>, Chris Metcalf <cmetcalf@tilera.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, uclinux-dist-devel@blackfin.uclinux.org, linux-cris-kernel@axis.com, linux-ia64@vger.kernel.org, linux-m32r@ml.linux-m32r.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linux-am33-list@redhat.com, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org

On Tue, May 3, 2011 at 5:30 PM, Sven Eckelmann <sven@narfation.org> wrote:
> diff --git a/arch/alpha/include/asm/atomic.h b/arch/alpha/include/asm/ato=
mic.h
> index e756d04..7e9434e 100644
> --- a/arch/alpha/include/asm/atomic.h
> +++ b/arch/alpha/include/asm/atomic.h
> @@ -200,6 +200,7 @@ static __inline__ int atomic_add_unless(atomic_t *v, =
int a, int u)
> =A0}
>
> =A0#define atomic_inc_not_zero(v) atomic_add_unless((v), 1, 0)
> +#define atomic_dec_not_zero(v) atomic_add_unless((v), -1, 0)
>
> =A0/**
> =A0* atomic64_add_unless - add unless the number is a given value
> @@ -226,6 +227,7 @@ static __inline__ int atomic64_add_unless(atomic64_t =
*v, long a, long u)
> =A0}
>
> =A0#define atomic64_inc_not_zero(v) atomic64_add_unless((v), 1, 0)
> +#define atomic64_dec_not_zero(v) atomic64_add_unless((v), -1, 0)
>
> =A0#define atomic_add_negative(a, v) (atomic_add_return((a), (v)) < 0)
> =A0#define atomic64_add_negative(a, v) (atomic64_add_return((a), (v)) < 0)
> diff --git a/arch/alpha/include/asm/local.h b/arch/alpha/include/asm/loca=
l.h
> index b9e3e33..09fb327 100644
> --- a/arch/alpha/include/asm/local.h
> +++ b/arch/alpha/include/asm/local.h
> @@ -79,6 +79,7 @@ static __inline__ long local_sub_return(long i, local_t=
 * l)
> =A0 =A0 =A0 =A0c !=3D (u); =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> =A0})
> =A0#define local_inc_not_zero(l) local_add_unless((l), 1, 0)
> +#define local_dec_not_zero(l) local_add_unless((l), -1, 0)
>
> =A0#define local_add_negative(a, l) (local_add_return((a), (l)) < 0)
>

Acked-by: Matt Turner <mattst88@gmail.com> [alpha]
