From: Kees Cook <keescook@chromium.org>
Date: Wed, 13 Oct 2021 07:02:41 +0000
Subject: Re: [PATCH v1 07/10] lkdtm: Force do_nothing() out of line
Message-Id: <202110130002.0FC7878252@keescook>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1633964380.git.christophe.leroy@csgroup.eu>
 <b353a85e50ac336c385b46459a5fc43f4a6171ac.1633964380.git.christophe.leroy@csgroup.eu>
In-Reply-To: <b353a85e50ac336c385b46459a5fc43f4a6171ac.1633964380.git.christophe.leroy@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christophe Leroy <christophe.leroy@csgroup.eu>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Mon, Oct 11, 2021 at 05:25:34PM +0200, Christophe Leroy wrote:
> LKDTM tests display that the run do_nothing() at a given
> address, but in reality do_nothing() is inlined into the
> caller.
> 
> Force it out of line so that it really runs text at the
> displayed address.
> 
> Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>

Acked-by: Kees Cook <keescook@chromium.org>

-- 
Kees Cook
