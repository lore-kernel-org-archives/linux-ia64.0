From: Jim Wilson <wilson@cygnus.com>
Date: Wed, 06 Dec 2000 20:16:06 +0000
Subject: Re: [Linux-ia64] static gcc from toolchain: howto?
Message-Id: <marc-linux-ia64-105590678205799@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205796@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205796@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> When I try and set LDFLAGS or LDFLAGS_FOR_TARGET to
>-static, I get lots of multiple to _nl_* stuff, hence only i18n stuff...

What I used to do was just replace the intl/libintl.a files with empty
archives.

cd intl
rm libintl.a
ar rc libintl.a
cd ..

There are two of these directories, intl, and gcc/intl.  I think this is the
easiest solution.

The real solution is to build and install gettext before running configure.
autoconf checks to see if the host has i18n support by trying to run xgettext.
If the program isn't there, then it assumes that we need to build our own
i18n library.  If you link against a shared glibc, this isn't a problem.
If you link against a static glibc, then you get the multiple definitions
link error.  I suppose if you don't have gcc yet, then building gettext might
be a problem.  So you will need to use a workaround once to bootstrap.

Bill Nottingham's suggestion of using --disable-nls should work too, but you
have to remember to use it before running configure.

Jim

