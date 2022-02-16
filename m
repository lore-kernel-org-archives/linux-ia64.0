From: Kees Cook <keescook@chromium.org>
Date: Wed, 16 Feb 2022 16:20:02 +0000
Subject: Re: [PATCH v4 00/13] Fix LKDTM for PPC64/IA64/PARISC v4
Message-Id: <202202160818.7C3862B@keescook>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1644928018.git.christophe.leroy@csgroup.eu>
 <202202150807.D584917D34@keescook>
 <87y22bm25y.fsf@mpe.ellerman.id.au>
In-Reply-To: <87y22bm25y.fsf@mpe.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Christophe Leroy <christophe.leroy@csgroup.eu>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Wed, Feb 16, 2022 at 11:22:33PM +1100, Michael Ellerman wrote:
> Kees Cook <keescook@chromium.org> writes:
> > On Tue, Feb 15, 2022 at 01:40:55PM +0100, Christophe Leroy wrote:
> >> PPC64/IA64/PARISC have function descriptors. LKDTM doesn't work
> >> on those three architectures because LKDTM messes up function
> >> descriptors with functions.
> >> 
> >> This series does some cleanup in the three architectures and
> >> refactors function descriptors so that it can then easily use it
> >> in a generic way in LKDTM.
> >
> > Thanks for doing this! It looks good to me. :)
> 
> How should we merge this series, it's a bit all over the map.
> 
> I could put it in a topic branch?

That's fine by me -- I had assumed it'd go via the ppc tree. But if
you'd rather I take it as a topic branch I can do that too.

-- 
Kees Cook
