From: Tim Riker <TimR@CalderaSystems.com>
Date: Wed, 23 Feb 2000 07:10:10 +0000
Subject: Re: [Linux-ia64] building the toolchain
Message-Id: <marc-linux-ia64-105590678204965@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678204943@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678204943@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

One should keep in mind that source RPMs tipically do both. They use one
prefix when building so that all binaries get the right paths as Jim
mentioned. An then they install with a different prefix so that the
files get installed into a prefixed virtual tree that can be packaged.
When the package is unpacked the files are unpacked into the correct
locations that the binaries are expecting.

build prefix might be /usr and install prefix /tmp/package-version/usr
and so on.

Jim Wilson wrote:
> 
>         The only trouble I had was with 'make install prefix=/usr/local/ia64/'
>         command, where the Makefile in build/itcl/iwidgets3.0.0/unix needed to be
>         fixed a bit, to point to the TCL and TK directories within the top-level src
>         directory.
> 
> The recommended way to build the toolchain is to specify prefix when
> configuring, not when installing.  E.g., something like
>         configure --prefix=/usr/local/ia64 ...
>         make all
>         make install
> If you give the prefix at configure time, then programs with builtin pathnames
> will have the correct pathnames.  If you give the prefix at install time,
> some programs may fail to work, unless you set an environment variable or
> use a command line option to override the default pathnames.
> 
> If you did not specify a prefix to configure, this may explain why
> itcl/iwidgets3.0.0/unix got confused.  configure thought you were building
> something for /usr/local by default, it noticed that there was already tcl/tk
> stuff in /usr/local, and tried to use it.  This stuff is obviously wrong for
> a cross compiler though.  And it is also wrong because you ended up with
> pathnames pointing to someone else's tcl/tk source tree.
> 
>         What I haven't yet seen is a glibc release (with include files) that lets
>         you build even simple IA64 apps.
> 
> This is unfortunate.
> 
> However, there are glibc sources in /usr/src on the OS CD-rom.  If you are
> feeling adventurous, you could try to compile them yourself.  I haven't
> tried this myself.  I'll probably wait until the linux distributors have
> something ready.
> 
> Jim
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Tim Riker - http://rikers.org/ - short SIGs! <g>
All I need to know I could have learned in Kindergarten
... if I'd just been paying attention.


