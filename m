From: Jim Wilson <wilson@cygnus.com>
Date: Mon, 19 Nov 2001 22:13:09 +0000
Subject: Re: [Linux-ia64] gcc 3.0.2 questions
Message-Id: <marc-linux-ia64-105590698805536@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805477@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805477@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Configure in /usr/src/gnu/build-gcc/fastjar failed, exiting.
>Is there anyway if disabling this?

If you rename the fastjar directory in your source tree, then configure
won't find it.  fastjar should configure OK for a simple cross compiler
though.

>./gengenrtl -h >tmp-genrtl.h
>make[1]: *** [s-genrtl] Error 4

>Is this related to the fastjar failure.

This isn't caused by the fastjar problem.  However, it may be failing for
the same reason.

gengenrtl is the first program run on the build machine when doing a gcc build.
If gengenrtl fails, then that may indicate that your configure build, host,
and/or target options are wrong.  That same problem could have caused the
fastjar configure error.

How did you configure the cross compiler?  Check the config.status and
gcc/config.status files to make sure that the build/host/target options are
what you expected.

Jim

