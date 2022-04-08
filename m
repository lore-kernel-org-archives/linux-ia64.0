From: Kees Cook <keescook@chromium.org>
Date: Fri, 08 Apr 2022 03:42:32 +0000
Subject: Re: [RFC PATCH] lkdtm: Replace lkdtm_rodata_do_nothing() by do_nothing()
Message-Id: <202204072037.FE91C45E@keescook>
List-Id: <linux-ia64.vger.kernel.org>
References: <fe36bf23fb14e7eff92a95a1092ed38edb01d5f5.1634491011.git.christophe.leroy@csgroup.eu>
In-Reply-To: <fe36bf23fb14e7eff92a95a1092ed38edb01d5f5.1634491011.git.christophe.leroy@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christophe Leroy <christophe.leroy@csgroup.eu>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Sun, Oct 17, 2021 at 07:19:47PM +0200, Christophe Leroy wrote:
> But for EXEC_RODATA test, execute_location() uses
> lkdtm_rodata_do_nothing() which is already in rodata section
> at build time instead of using a copy of do_nothing(). However
> it still uses the function descriptor of do_nothing(). There
> is a risk that running lkdtm_rodata_do_nothing() with the
> function descriptor of do_thing() is wrong.

Wrong how? (Could there be two descriptors?)

> To remove the above risk, change the approach and do the same
> as for other EXEC tests: use a copy of do_nothing(). The copy
> cannot be done during the test because RODATA area is write
> protected. Do the copy during init, before RODATA becomes
> write protected.

Hmm, hmm. This is a nice way to handle it, but I'm not sure which
"weird" way is better. I kind of prefer the code going through all the
"regular" linking goo to end up in .rodata, but is it really any
different from doing this via the ro_after_init section? It makes me
nervous because they can technically be handled differently. For
example, .rodata is mapped differently on some architectures compared to
ro_after_init. Honestly, I actually this this patch should be modified
to _add_ a new test for EXEC_RO_AFTER_INIT, and leave the existing
.rodata one alone...

-Kees

-- 
Kees Cook
