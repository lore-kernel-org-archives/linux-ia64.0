From: Kees Cook <keescook@chromium.org>
Date: Wed, 09 Mar 2022 16:30:17 +0000
Subject: Re: [PATCH v4 00/13] Fix LKDTM for PPC64/IA64/PARISC v4
Message-Id: <202203090829.53A243306@keescook>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1644928018.git.christophe.leroy@csgroup.eu>
 <164674125384.3322453.12551849351633372798.b4-ty@ellerman.id.au>
 <87r17bnbxx.fsf@mpe.ellerman.id.au>
In-Reply-To: <87r17bnbxx.fsf@mpe.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Michael Ellerman <patch-notifications@ellerman.id.au>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Helge Deller <deller@gmx.de>, Christophe Leroy <christophe.leroy@csgroup.eu>, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Arnd Bergmann <arnd@arndb.de>, linuxppc-dev@lists.ozlabs.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Mar 09, 2022 at 12:37:14PM +1100, Michael Ellerman wrote:
> Michael Ellerman <patch-notifications@ellerman.id.au> writes:
> > On Tue, 15 Feb 2022 13:40:55 +0100, Christophe Leroy wrote:
> >> PPC64/IA64/PARISC have function descriptors. LKDTM doesn't work
> >> on those three architectures because LKDTM messes up function
> >> descriptors with functions.
> >> 
> >> This series does some cleanup in the three architectures and
> >> refactors function descriptors so that it can then easily use it
> >> in a generic way in LKDTM.
> >> 
> >> [...]
> >
> > Applied to powerpc/next.
> 
> I also have it in an rc2-based topic branch if there are any merge
> conflicts that people want to resolve, I don't see any in linux-next at
> the moment though.
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/powerpc/linux.git/log/?h=topic/func-desc-lkdtm

Thanks! I've got some core changes coming for lkdtm, but I'm waiting
until after the merge window to rebase them and get them into -next.

-- 
Kees Cook
