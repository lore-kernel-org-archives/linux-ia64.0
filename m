From: Jim Wilson <wilson@cygnus.com>
Date: Fri, 12 Jan 2001 00:34:25 +0000
Subject: Re: [Linux-ia64] Problem to build Kernel 2.4.0 with gcc version "2.96-ia64-000717" + snap "001117"
Message-Id: <marc-linux-ia64-105590693005033@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005032@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005032@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>experienced compilation errors with the specific
>"net/ipv4/netfilter/ip_tables.c" source file.

See the file ftp.cygnus.com:pub/ia64-linux/snap-001117/WORKAROUND.cpp.kernel,
available since Nov 17.

The gcc c preprocessor was rewritten 3 or 4 times this year, and this
particular bug was fixed in the last rewrite which was sometime in late
October I think.  However, since there is no guarantee that the final rewrite
is perfect, so it is safer to work around the problem for now.

>This points to some regression between latest gcc versions vs Linux Kernel
>source files content and the syntax used (there was a lot of warnings about
>"depracated" use of "##" constructs during the Kernel build but the only
>error found) and may be highlights the need of a "generic" gcc ship+use for
>Kernel builds ...

As part of the many rewrites, the C preprocessor now has better compliance
to ISO C, and some GNU extensions have been deprecated.  However, you shouldn't
pay too much attention to the warnings you get from this July FSF snapshot,
because this cpp behaviour changed several times after that.  Better to
try the current FSF gcc sources and worry about those warnings.  I'd suspect
other people have already done this.

Your comment about a "generic" gcc for kernel builds makes no sense.  This
is the gcc to use for kernel builds.  There is no other IA-64 gcc that is
usable.

Jim

