From: Thomas Gleixner <tglx@linutronix.de>
Date: Thu, 07 Jul 2016 07:42:17 +0000
Subject: Re: [PATCH 1/9] mm: Hardened usercopy
Message-Id: <alpine.DEB.2.11.1607070938430.4083@nanos>
List-Id: <linux-ia64.vger.kernel.org>
References: <1467843928-29351-1-git-send-email-keescook@chromium.org> <1467843928-29351-2-git-send-email-keescook@chromium.org>
In-Reply-To: <1467843928-29351-2-git-send-email-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kees Cook <keescook@chromium.org>
Cc: linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, x86@kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

On Wed, 6 Jul 2016, Kees Cook wrote:
> +
> +#if defined(CONFIG_FRAME_POINTER) && defined(CONFIG_X86)
> +	const void *frame = NULL;
> +	const void *oldframe;
> +#endif

That's ugly

> +
> +	/* Object is not on the stack at all. */
> +	if (obj + len <= stack || stackend <= obj)
> +		return 0;
> +
> +	/*
> +	 * Reject: object partially overlaps the stack (passing the
> +	 * the check above means at least one end is within the stack,
> +	 * so if this check fails, the other end is outside the stack).
> +	 */
> +	if (obj < stack || stackend < obj + len)
> +		return -1;
> +
> +#if defined(CONFIG_FRAME_POINTER) && defined(CONFIG_X86)
> +	oldframe = __builtin_frame_address(1);
> +	if (oldframe)
> +		frame = __builtin_frame_address(2);
> +	/*
> +	 * low ----------------------------------------------> high
> +	 * [saved bp][saved ip][args][local vars][saved bp][saved ip]
> +	 *		     ^----------------^
> +	 *             allow copies only within here
> +	 */
> +	while (stack <= frame && frame < stackend) {
> +		/*
> +		 * If obj + len extends past the last frame, this
> +		 * check won't pass and the next frame will be 0,
> +		 * causing us to bail out and correctly report
> +		 * the copy as invalid.
> +		 */
> +		if (obj + len <= frame)
> +			return obj >= oldframe + 2 * sizeof(void *) ? 2 : -1;
> +		oldframe = frame;
> +		frame = *(const void * const *)frame;
> +	}
> +	return -1;
> +#else
> +	return 1;
> +#endif

I'd rather make that a weak function returning 1 which can be replaced by
x86 for CONFIG_FRAME_POINTER=y. That also allows other architectures to
implement their specific frame checks.

Thanks,

	tglx
