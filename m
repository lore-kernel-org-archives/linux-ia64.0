From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Tue, 06 Feb 2018 09:34:50 +0000
Subject: Re: [PATCH 06/14] kbuild: define PYTHON2 and PYTHON3 variables instead of PYTHON
Message-Id: <20180206093450.GB31558@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1517877294-4826-1-git-send-email-yamada.masahiro@socionext.com>
 <1517877294-4826-7-git-send-email-yamada.masahiro@socionext.com>
In-Reply-To: <1517877294-4826-7-git-send-email-yamada.masahiro@socionext.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: linux-kbuild@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, "Luis R . Rodriguez" <mcgrof@suse.com>, Randy Dunlap <rdunlap@infradead.org>, Ulf Magnusson <ulfalizer@gmail.com>, Sam Ravnborg <sam@ravnborg.org>, Michal Marek <michal.lkml@markovi.net>, Linus Torvalds <torvalds@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>

On Tue, Feb 06, 2018 at 09:34:46AM +0900, Masahiro Yamada wrote:
> The variable 'PYTHON' allows users to specify a proper executable
> name in case the default 'python' does not work.  However, this does
> not address the case where both Python 2 and Python 3 scripts are
> used in one system.
> 
> PEP 394 (https://www.python.org/dev/peps/pep-0394/) provides a
> convention for Python scripts portability.  Here is a quotation:
> 
>   In order to tolerate differences across platforms, all new code
>   that needs to invoke the Python interpreter should not specify
>   'python', but rather should specify either 'python2' or 'python3'.
>   This distinction should be made in shebangs, when invoking from a
>   shell script, when invoking via the system() call, or when invoking
>   in any other context.
> 
> arch/ia64/scripts/unwcheck.py is apparently written in Python 2, so
> it should be invoked by 'python2'.
> 
> It is legitimate to use 'python' for scripts compatible with both
> Python 2 and Python 3, but this is rare (at least I do not see the
> case in kernel tree).  You do not need to make efforts to write your
> scripts in that way.  Anyway, Python 2 will retire in 2020.
> 
> This commit is needed for my new scripts written in Python 3.
> 
> Signed-off-by: Masahiro Yamada <yamada.masahiro@socionext.com>
> ---
> 
>  Makefile           | 5 +++--
>  arch/ia64/Makefile | 2 +-
>  2 files changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/Makefile b/Makefile
> index 11aff0f..c4e935c 100644
> --- a/Makefile
> +++ b/Makefile
> @@ -384,7 +384,8 @@ GENKSYMS	= scripts/genksyms/genksyms
>  INSTALLKERNEL  := installkernel
>  DEPMOD		= /sbin/depmod
>  PERL		= perl
> -PYTHON		= python
> +PYTHON2		= python2
> +PYTHON3		= python3

Is this going to break any systems that were previous setting PYTHON?

I like this change, and feel it is the correct thing to do, but having a
"fallback" might be needed here.

Could you do what the perf makefile does and do something like:
	override PYTHON := $(call get-executable-or-default,PYTHON,$(PYTHON2))
or is it really not an issue as only ia64 seems to care about this?

thanks,

greg k-h
