From: Roland McGrath <roland@redhat.com>
Date: Thu, 09 Jan 2003 07:05:55 +0000
Subject: [Linux-ia64] Re: strace improvement patch
Message-Id: <marc-linux-ia64-105590709805653@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805650@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805650@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>  * util.c (arg_setup) [IA64]: Make it work for syscall-stubs that have
> 	a non-empty local register partition.
>    (set_arg0) [IA64]: Fix it so it actually works.
>    (set_arg1) [IA64]: Ditto.
>    (setbpt): Treat SYS_clone2 like SYS_clone.

Are you sure this really works on IA64?  I've merged the changes, and
though I fixed some other problems with my original code, the IA64 code in
util.c is exactly what's in your patch.  It doesn't work for me on IA64.
The failure mode suggests the argument munging code is munging the wrong
thing.  I don't know IA64 halfway well enough to figure out how it might be
wrong, and it looks to me like it matches the code that fetches those
values in syscall_enter.  When I do "strace -f /usr/bin/time /bin/true",
both parent and child die with SIGSEGV upon continuing the clone syscall
whose arguments should have been munged to set the CLONE_PTRACE flag.
(It executes fine without -f.)

I've committed the changes (along with some more fixes and new support for
the new threads features in Linux 2.5).  Can you get the current sources
from sourceforge and try them on IA64?  After getting a cvs checkout,
you'll need to run "autoreconf -i" with automake-1.7.2 and autoconf-2.57.

Unless someone can help me fix this right away, we'll probably go ahead
with a 4.4.90 test release with this bug still biting IA64.


Thanks,
Roland


