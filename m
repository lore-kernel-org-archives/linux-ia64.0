From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 18 Oct 2001 23:03:01 +0000
Subject: Re: [Linux-ia64] sscanf() broken on ia64
Message-Id: <marc-linux-ia64-105590698805371@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805369@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805369@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 18 Oct 2001 16:50:28 -0500, 
"David J. Morse" <david.morse@onebox.com> wrote:
>I'm having a problem with sscanf() on IA-64; it seems to be able to parse
>a string into arguments correctly when whitespace is the delimiter, but
>not "."!

lib/vsprintf.c::vscanf had a bug in handling non-format characters.  It
was corrected in 2.4.13-pre3.  Try copying lib/vsprintf.c from a
current Linus kernel into your IA64 kernel.

>/* Declare what kind of code we want from the header files */
>#define __KERNEL__         /* We're part of the kernel */
>#define MODULE             /* Not a permanent part, though. */
>
>/* Standard headers for LKMs */
>#include <linux/modversions.h> 
>#include <linux/module.h>  

Unrelated to the scanf problem.  Please do not #define those symbols
nor include modversions.h in modules, even sample ones, the symbols and
include should be handled via the command line.  That code will break
in kernel 2.5 with my new kernel build system.


