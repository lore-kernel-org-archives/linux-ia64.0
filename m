From: Jim Wilson <wilson@cygnus.com>
Date: Wed, 24 Jan 2001 21:37:24 +0000
Subject: Re: [Linux-ia64] The 1117 snapshot cpp problem
Message-Id: <marc-linux-ia64-105590693005090@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205880@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205880@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>I guess it is a long standing issue in the Cygnus toolchain. The
>problem is this change:
>Bascallly, it sets local_prefix = prefix, which means
>$local_prefix/include = $prefix/include

>Now, gcc will search /usr/include before others. It is not very good
>for Linux.

Yes, this is a problem.

I've reverted the Cygnus local change in my source tree, and have started
working to get the same change into the main Cygnus source tree.  This will
require changing some local build processes, so it may take a little time.

There is no problem with cross compilers as you suggested, because cross
compilers don't use /usr/local/include.  I believe the original problem was
that we shipped compilers to some customers that had random files in
/usr/local, the customers reported problems, and we had a lot of trouble
debugging the problem.  We fixed it by deciding not to use /usr/local/include
by default anymore.  This was 8 years ago, so Linux usage was not a concern.
Now that we are part of Red Hat, it is a serious concern.

The resulting patch is 100K because configure had to be rebuilt.  I put it
in the usual place, ftp.cygnus.com:/pub/ia64-linux/snap-001117/patch.055.

Jim

