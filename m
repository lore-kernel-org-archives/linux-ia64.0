From: Paulo Marques <pmarques@grupopie.com>
Date: Mon, 27 Dec 2004 13:00:34 +0000
Subject: Re: Announce: kdb v4.4 is available for kernel 2.6.10
Message-Id: <41D00772.1050600@grupopie.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <18921.1103977059@ocs3.ocs.com.au>
In-Reply-To: <18921.1103977059@ocs3.ocs.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Keith Owens <kaos@sgi.com>
Cc: kdb@oss.sgi.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Keith Owens wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> KDB (Linux Kernel Debugger) has been updated.

Hi,

I browsed the patch quickly to check for kallsyms uses, and validate 
them, and it generally seems correct.

There is however one comment that makes me wonder:
*2.6 kallsyms has a "feature" where it unpacks the name into a string.
*If that string is reused before the caller expects it then the caller
*sees its string change without warning.

kallsyms_lookup always uses the buffer passed to it in the case the 
symbol is a kernel symbol, as opposed to a module symbol, and so it is 
not responsible for the buffer.

So this probably only happens when a module symbol is returned directly 
from its symbol table, and then the module is unloaded (or something 
like that).

Later there is another comment:
* Another 2.6 kallsyms "feature".  Sometimes the sym_name is
* set but the buffer passed into kallsyms_lookup is not used,
* so it contains garbage.

It seems to be the same problem. If we modify kallsyms_lookup to always 
use the buffer passed, even if the symbol comes from a module, maybe we 
could solve both problems with just one change.

On the downside, a caller that just wants to print the name, would pay 
an unnecessary string copy.

On the upside, this would make the interface more coherent with standard 
C functions like strcpy, where the buffer passed is always the buffer 
returned.

So, is it worth the change?

-- 
Paulo Marques - www.grupopie.com

"A journey of a thousand miles begins with a single step."
Lao-tzu, The Way of Lao-tzu

