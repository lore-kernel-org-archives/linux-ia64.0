From: Jim Wilson <wilson@cygnus.com>
Date: Fri, 16 Mar 2001 18:31:08 +0000
Subject: Re: [Linux-ia64] Fortran compiler for ia64?
Message-Id: <marc-linux-ia64-105590693005287@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005278@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005278@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>All is in $subject... The existing toolchain doesn't seem to have any support
>for Fortran right now.

The Red Hat tools group (formerly Cygnus) does not support Fortran, so Fortran
is not present in our releases.  Fortran is present in the FSF gcc tree
though, and should be working fine.  Here are test results from a couple of
days ago off the gcc3 branch:

		== g77 Summary =
# of expected passes		904
# of unexpected failures	9
# of untested testcases		6
# of unsupported tests		8

This is very close to the x86 testsuite results.

>Oh, and the linux-ia64 website and cygnus FTP site are still down... Is this
>normal?

Yes, the cygnus ftp site is still down.  It has been down for over a week,
and I still don't have any estimate for when it will be back up.

At this point though, I don't think it really matters anymore.  I'd been
planning for a while to phase out the last compiler release in favor of gcc3.  
I may as well use the ftp site problems to effect the change.  If you still
need the old compiler, you can get source RPMS from Red Hat, Suse, Turbolinux,
etc.  Meanwhile, gcc3 is still not stable enough for building distributions,
but it should be stable enough for most development work.

Jim

