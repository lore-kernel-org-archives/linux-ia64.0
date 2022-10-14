From: Miguel Ojeda <miguel.ojeda.sandonis@gmail.com>
Date: Fri, 14 Oct 2022 14:39:59 +0000
Subject: Re: [PATCH v2] Remove Intel compiler support
Message-Id: <CANiq72kvaPGr=2S6J7q7gfEg_CauHUfhuLmABpktfUPfK+_Hvg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221011171427.58891-1-masahiroy@kernel.org>
In-Reply-To: <20221011171427.58891-1-masahiroy@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masahiro Yamada <masahiroy@kernel.org>, Nick Terrell <terrelln@fb.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H . Peter Anvin" <hpa@zytor.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-ia64@vger.kernel.org, Nick Desaulniers <ndesaulniers@google.com>, Miguel Ojeda <ojeda@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Len Brown <lenb@kernel.org>, Nathan Chancellor <nathan@kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Robert Moore <robert.moore@intel.com>, Tom Rix <trix@redhat.com>, devel@acpica.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, llvm@lists.linux.dev

On Tue, Oct 11, 2022 at 7:16 PM Masahiro Yamada <masahiroy@kernel.org> wrote:
>
> diff --git a/include/linux/compiler_attributes.h b/include/linux/compiler_attributes.h
> index 898b3458b24a..9221302f6ae8 100644
> --- a/include/linux/compiler_attributes.h
> +++ b/include/linux/compiler_attributes.h
> @@ -64,16 +64,10 @@
>   * compiler should see some alignment anyway, when the return value is
>   * massaged by 'flags = ptr & 3; ptr &= ~3;').
>   *
> - * Optional: not supported by icc
> - *
>   *   gcc: https://gcc.gnu.org/onlinedocs/gcc/Common-Function-Attributes.html#index-assume_005faligned-function-attribute
>   * clang: https://clang.llvm.org/docs/AttributeReference.html#assume-aligned
>   */
> -#if __has_attribute(__assume_aligned__)
> -# define __assume_aligned(a, ...)       __attribute__((__assume_aligned__(a, ## __VA_ARGS__)))
> -#else
> -# define __assume_aligned(a, ...)
> -#endif
> +#define __assume_aligned(a, ...)        __attribute__((__assume_aligned__(a, ## __VA_ARGS__)))

Thanks for cleaning the conditional inclusion here. I double-checked
it is indeed available for both GCC and Clang current minimum versions
just in case: https://godbolt.org/z/PxaqeEdcE.

> diff --git a/lib/zstd/common/compiler.h b/lib/zstd/common/compiler.h
> index f5a9c70a228a..c281a6430cd4 100644
> --- a/lib/zstd/common/compiler.h
> +++ b/lib/zstd/common/compiler.h
> @@ -116,7 +116,7 @@
>
>  /* vectorization
>   * older GCC (pre gcc-4.3 picked as the cutoff) uses a different syntax */
> -#if !defined(__INTEL_COMPILER) && !defined(__clang__) && defined(__GNUC__)
> +#if !defined(__clang__) && defined(__GNUC__)
>  #  if (__GNUC__ = 4 && __GNUC_MINOR__ > 3) || (__GNUC__ >= 5)
>  #    define DONT_VECTORIZE __attribute__((optimize("no-tree-vectorize")))
>  #  else

These files come from upstream Zstandard -- should we keep those lines
to minimize divergence?
https://github.com/facebook/zstd/blob/v1.4.10/lib/common/compiler.h#L154.

Commit e0c1b49f5b67 ("lib: zstd: Upgrade to latest upstream zstd
version 1.4.10") is the latest upgrade, and says:

    This patch is 100% generated from upstream zstd commit 20821a46f412 [0].

    This patch is very large because it is transitioning from the custom
    kernel zstd to using upstream directly. The new zstd follows upstreams
    file structure which is different. Future update patches will be much
    smaller because they will only contain the changes from one upstream
    zstd release.

So I think Nick would prefer to keep the changes as minimal as
possible with respect to upstream.

Further reading seems to suggest this is the case, e.g. see this
commit upstream that introduces a space to match the kernel:
https://github.com/facebook/zstd/commit/b53da1f6f499f0d44c5f40795b080d967b24e5fa.

> diff --git a/lib/zstd/compress/zstd_fast.c b/lib/zstd/compress/zstd_fast.c
> index 96b7d48e2868..800f3865119f 100644
> --- a/lib/zstd/compress/zstd_fast.c
> +++ b/lib/zstd/compress/zstd_fast.c
> @@ -80,13 +80,6 @@ ZSTD_compressBlock_fast_generic(
>      }
>
>      /* Main Search Loop */
> -#ifdef __INTEL_COMPILER
> -    /* From intel 'The vector pragma indicates that the loop should be
> -     * vectorized if it is legal to do so'. Can be used together with
> -     * #pragma ivdep (but have opted to exclude that because intel
> -     * warns against using it).*/
> -    #pragma vector always
> -#endif
>      while (ip1 < ilimit) {   /* < instead of <=, because check at ip0+2 */
>          size_t mLength;
>          BYTE const* ip2 = ip0 + 2;

Ditto: https://github.com/facebook/zstd/blob/v1.4.10/lib/compress/zstd_fast.c#L83.

Apart from the zstd divergence which I am not sure about, everything
looks good to me!

Reviewed-by: Miguel Ojeda <ojeda@kernel.org>

Cheers,
Miguel
