From: Ralf Baechle <ralf@linux-mips.org>
Date: Mon, 03 Aug 2015 06:02:17 +0000
Subject: Re: [PATCH v2] arch: use WRITE_ONCE/READ_ONCE in smp_store_release/smp_load_acquire
Message-Id: <20150803060217.GB16650@linux-mips.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1438528264-714-1-git-send-email-andreyknvl@google.com>
In-Reply-To: <1438528264-714-1-git-send-email-andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, James Hogan <james.hogan@imgtec.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Peter Zijlstra <peterz@infradead.org>, Alexander Duyck <alexander.h.duyck@redhat.com>, Andre Przywara <andre.przywara@arm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Borislav Petkov <bp@suse.de>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Davidlohr Bueso <dave@stgolabs.net>

On Sun, Aug 02, 2015 at 05:11:04PM +0200, Andrey Konovalov wrote:

> diff --git a/arch/mips/include/asm/barrier.h b/arch/mips/include/asm/barrier.h
> index 7ecba84..752e0b8 100644
> --- a/arch/mips/include/asm/barrier.h
> +++ b/arch/mips/include/asm/barrier.h
> @@ -133,12 +133,12 @@
>  do {									\
>  	compiletime_assert_atomic_type(*p);				\
>  	smp_mb();							\
> -	ACCESS_ONCE(*p) = (v);						\
> +	WRITE_ONCE(*p, v);						\
>  } while (0)
>  
>  #define smp_load_acquire(p)						\
>  ({									\
> -	typeof(*p) ___p1 = ACCESS_ONCE(*p);				\
> +	typeof(*p) ___p1 = READ_ONCE(*p);				\
>  	compiletime_assert_atomic_type(*p);				\
>  	smp_mb();							\
>  	___p1;								\

Acked-by: Ralf Baechle <ralf@linux-mips.org>

  Ralf
