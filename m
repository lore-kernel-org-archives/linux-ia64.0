From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Tue, 06 Feb 2018 13:10:17 +0000
Subject: Re: [PATCH 06/14] kbuild: define PYTHON2 and PYTHON3 variables instead of PYTHON
Message-Id: <20180206131017.GF31804@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1517877294-4826-1-git-send-email-yamada.masahiro@socionext.com>
 <1517877294-4826-7-git-send-email-yamada.masahiro@socionext.com>
 <20180206093450.GB31558@kroah.com>
 <CAK7LNAS_29myncTw+6u7fH9BgjzZJfXSN1CJjOjK-qXjPRQ8hQ@mail.gmail.com>
In-Reply-To: <CAK7LNAS_29myncTw+6u7fH9BgjzZJfXSN1CJjOjK-qXjPRQ8hQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, "Luis R . Rodriguez" <mcgrof@suse.com>, Randy Dunlap <rdunlap@infradead.org>, Ulf Magnusson <ulfalizer@gmail.com>, Sam Ravnborg <sam@ravnborg.org>, Michal Marek <michal.lkml@markovi.net>, Linus Torvalds <torvalds@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Fenghua Yu <fenghua.yu@intel.com>

On Tue, Feb 06, 2018 at 07:44:22PM +0900, Masahiro Yamada wrote:
> 2018-02-06 18:34 GMT+09:00 Greg Kroah-Hartman <gregkh@linuxfoundation.org>:
> > On Tue, Feb 06, 2018 at 09:34:46AM +0900, Masahiro Yamada wrote:
> >> The variable 'PYTHON' allows users to specify a proper executable
> >> name in case the default 'python' does not work.  However, this does
> >> not address the case where both Python 2 and Python 3 scripts are
> >> used in one system.
> >>
> >> PEP 394 (https://www.python.org/dev/peps/pep-0394/) provides a
> >> convention for Python scripts portability.  Here is a quotation:
> >>
> >>   In order to tolerate differences across platforms, all new code
> >>   that needs to invoke the Python interpreter should not specify
> >>   'python', but rather should specify either 'python2' or 'python3'.
> >>   This distinction should be made in shebangs, when invoking from a
> >>   shell script, when invoking via the system() call, or when invoking
> >>   in any other context.
> >>
> >> arch/ia64/scripts/unwcheck.py is apparently written in Python 2, so
> >> it should be invoked by 'python2'.
> >>
> >> It is legitimate to use 'python' for scripts compatible with both
> >> Python 2 and Python 3, but this is rare (at least I do not see the
> >> case in kernel tree).  You do not need to make efforts to write your
> >> scripts in that way.  Anyway, Python 2 will retire in 2020.
> >>
> >> This commit is needed for my new scripts written in Python 3.
> >>
> >> Signed-off-by: Masahiro Yamada <yamada.masahiro@socionext.com>
> >> ---
> >>
> >>  Makefile           | 5 +++--
> >>  arch/ia64/Makefile | 2 +-
> >>  2 files changed, 4 insertions(+), 3 deletions(-)
> >>
> >> diff --git a/Makefile b/Makefile
> >> index 11aff0f..c4e935c 100644
> >> --- a/Makefile
> >> +++ b/Makefile
> >> @@ -384,7 +384,8 @@ GENKSYMS  = scripts/genksyms/genksyms
> >>  INSTALLKERNEL  := installkernel
> >>  DEPMOD               = /sbin/depmod
> >>  PERL         = perl
> >> -PYTHON               = python
> >> +PYTHON2              = python2
> >> +PYTHON3              = python3
> >
> > Is this going to break any systems that were previous setting PYTHON?
> >
> > I like this change, and feel it is the correct thing to do, but having a
> > "fallback" might be needed here.
> >
> > Could you do what the perf makefile does and do something like:
> >         override PYTHON := $(call get-executable-or-default,PYTHON,$(PYTHON2))
> > or is it really not an issue as only ia64 seems to care about this?
> >
> 
> As far as I see, ia64 is the only instance that has used this ever.
> 
> (the perf Makefile defines PYTHON by itself, so should not be a problem.)
> 
> 
> If people expect the backward-compatibility for this, I can do like follows:
> 
> # backward compatibility for 'PYTHON'
> PYTHON2  := $(if $(PYTHON), $(PYTHON), python2)

That's true, and who knows if python3 is running on ia64 :)

> Another (unlikely) possible breakage is
> 'python2' may not be installed on users' system.
> 
> I believe this is rare, but if needed, I could do like follows
> at the cost of ugliness.
> 
> 
> PYTHON2 := $(if $(PYTHON), $(PYTHON), \
>         $(shell python2 --version 2>/dev/null && echo python2 || echo python))

Ick, I guess that might work.  Try getting your patch set into the 0-day
system to see how it handles things.  I know it builds for ia64.

But this is a real tiny question overall, and should not derail this
patchset at all :)

thanks,

greg k-h
