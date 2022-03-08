From: Michael Ellerman <patch-notifications@ellerman.id.au>
Date: Tue, 08 Mar 2022 12:07:33 +0000
Subject: Re: [PATCH v4 00/13] Fix LKDTM for PPC64/IA64/PARISC v4
Message-Id: <164674125384.3322453.12551849351633372798.b4-ty@ellerman.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1644928018.git.christophe.leroy@csgroup.eu>
In-Reply-To: <cover.1644928018.git.christophe.leroy@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Helge Deller <deller@gmx.de>, Christophe Leroy <christophe.leroy@csgroup.eu>, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>
Cc: linuxppc-dev@lists.ozlabs.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 15 Feb 2022 13:40:55 +0100, Christophe Leroy wrote:
> PPC64/IA64/PARISC have function descriptors. LKDTM doesn't work
> on those three architectures because LKDTM messes up function
> descriptors with functions.
> 
> This series does some cleanup in the three architectures and
> refactors function descriptors so that it can then easily use it
> in a generic way in LKDTM.
> 
> [...]

Applied to powerpc/next.

[01/13] powerpc: Fix 'sparse' checking on PPC64le
        https://git.kernel.org/powerpc/c/81df21de8fb45d3a55d41da9c7f5724797d51ce6
[02/13] powerpc: Move and rename func_descr_t
        https://git.kernel.org/powerpc/c/5b23cb8cc6b0aab0535253cc2aa362572bab7072
[03/13] powerpc: Use 'struct func_desc' instead of 'struct ppc64_opd_entry'
        https://git.kernel.org/powerpc/c/d3e32b997a4ca2e7be71cb770bcb2c000ee20b36
[04/13] powerpc: Remove 'struct ppc64_opd_entry'
        https://git.kernel.org/powerpc/c/0a9c5ae279c963149df9a84588281d3d607f7a1f
[05/13] powerpc: Prepare func_desc_t for refactorisation
        https://git.kernel.org/powerpc/c/2fd986377d546bedaf27e36554dc9090d272f15d
[06/13] ia64: Rename 'ip' to 'addr' in 'struct fdesc'
        https://git.kernel.org/powerpc/c/41a88b45479da873bfc5d29ba1a545a780c5329a
[07/13] asm-generic: Define CONFIG_HAVE_FUNCTION_DESCRIPTORS
        https://git.kernel.org/powerpc/c/a257cacc38718c83cee003487e03197f237f5c3f
[08/13] asm-generic: Define 'func_desc_t' to commonly describe function descriptors
        https://git.kernel.org/powerpc/c/0dc690e4ef5b901e9d4b53520854fbd5c749e09d
[09/13] asm-generic: Refactor dereference_[kernel]_function_descriptor()
        https://git.kernel.org/powerpc/c/e1478d8eaf27704db17a44dee4c53696ed01fc9c
[10/13] lkdtm: Force do_nothing() out of line
        https://git.kernel.org/powerpc/c/69b420ed8fd3917ac7073256b4929aa246b6fe31
[11/13] lkdtm: Really write into kernel text in WRITE_KERN
        https://git.kernel.org/powerpc/c/b64913394f123e819bffabc79a0e48f98e78dc5d
[12/13] lkdtm: Fix execute_[user]_location()
        https://git.kernel.org/powerpc/c/72a86433049dcfe918886645ac3d19c1eaaa67ab
[13/13] lkdtm: Add a test for function descriptors protection
        https://git.kernel.org/powerpc/c/5e5a6c5441654d1b9e576ce4ca8a1759e701079e

cheers
