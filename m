From: Keith Owens <kaos@ocs.com.au>
Date: Sat, 13 Apr 2002 01:55:13 +0000
Subject: Re: [Linux-ia64] Missing EXPORT_SYMBOL memset
Message-Id: <marc-linux-ia64-105590701905444@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905441@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905441@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, 13 Apr 2002 03:38:40 +0200, 
Andreas Schwab <schwab@suse.de> wrote:
>Keith Owens <kaos@ocs.com.au> writes:
>
>|> On Fri, 12 Apr 2002 17:05:37 +0200, 
>|> Andreas Schwab <schwab@suse.de> wrote:
>|> >GCC 3 may generate calls to memset, so we need to export it to modules.
>|> 
>|> If gcc does that the code does not use the arch tuned memset.  Also the
>|> memset function is only generated if __HAVE_ARCH_MEMSET is undefined,
>|> but include/asm-ia64/string.h defines __HAVE_ARCH_MEMSET.  We would be
>|> better off teaching gcc not to generate calls to memset where we do not
>|> want them so the kernel gets the code that we want, not what gcc thinks
>|> might be a good idea.
>
>There is no way for gcc to see the memset macro when it generates the call
>to the memset function.  And there isn't much lost anyway, since the macro
>is just there to call __bzero vs. __memset_generic (aka memset), the
>difference is just one parameter more or less.

I know about the "gcc decides to insert memset after cpp phase"
problem.  When it occurred in the past (it used to happen with gcc 2.7
in 2.[02] kernels) the response was always to change the source code to
prevent gcc making this wrong decision.  Adding and exporting a memset
function in the kernel is wrong, we need to fix gcc or change the
source code.


