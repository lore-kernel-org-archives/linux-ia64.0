From: Balbir Singh <bsingharora@gmail.com>
Date: Fri, 15 Jul 2016 02:05:50 +0000
Subject: Re: [PATCH v2 11/11] mm: SLUB hardened usercopy support
Message-Id: <20160715020550.GB13944@balbir.ozlabs.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1468446964-22213-1-git-send-email-keescook@chromium.org>
 <1468446964-22213-12-git-send-email-keescook@chromium.org>
In-Reply-To: <1468446964-22213-12-git-send-email-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kees Cook <keescook@chromium.org>
Cc: linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, x86@kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

On Wed, Jul 13, 2016 at 02:56:04PM -0700, Kees Cook wrote:
> Under CONFIG_HARDENED_USERCOPY, this adds object size checking to the
> SLUB allocator to catch any copies that may span objects. Includes a
> redzone handling fix from Michael Ellerman.
> 
> Based on code from PaX and grsecurity.
> 
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
>  init/Kconfig |  1 +
>  mm/slub.c    | 36 ++++++++++++++++++++++++++++++++++++
>  2 files changed, 37 insertions(+)
> 
> diff --git a/init/Kconfig b/init/Kconfig
> index 798c2020ee7c..1c4711819dfd 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -1765,6 +1765,7 @@ config SLAB
>  
>  config SLUB
>  	bool "SLUB (Unqueued Allocator)"
> +	select HAVE_HARDENED_USERCOPY_ALLOCATOR

Should this patch come in earlier from a build perspective? I think
patch 1 introduces and uses __check_heap_object.

Balbir Singh.
