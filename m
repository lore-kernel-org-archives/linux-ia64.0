From: gjertsen@us.ibm.com
Date: Thu, 05 Oct 2000 19:45:10 +0000
Subject: [Linux-ia64] info on kernel module debugging
Message-Id: <marc-linux-ia64-105590678205549@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


I need to be able to step through some of our kernel module code
at the assembly level, but it doesn't appear that I can do this while
running on a "real" IA64 box.
I am fairly sure that the problem I am encountering is not a bug in
our code (yeah ... trust me), but I can't isolate the root cause right now
because the machine just plain old freezes on me.

Answers to the following questions would help though:

1) I've tried using kdb to set breakpoints at kernel module functions
that were exported and this doesn't seem to work. I end up
getting a kernel oops and complaint about being unable to
handle the paging request. It appears to be stopping/panicking right
before I want it to, though, and kdb was willing to set a bp there. :)
Should I be able to do this or not?
I see that kdb works fine when I set up break points for
functions in the kernel itself. (I'm currently using turbolinux test8
kernel).

2) Is there any sort of approx. timeline for when the remote kernel
debugger
will be available for IA64 (kgdb)?

3) Does the magic system request key work on this platform? I've tried it
out with
no luck and my autoconf file indicates CONFIG_MAGIC_SYSRQ is enabled.
Something else I need to be doing here?

Thanks for any pointers,

--Rob



