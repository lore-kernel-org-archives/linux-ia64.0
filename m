From: Jim Wilson <wilson@cygnus.com>
Date: Wed, 07 Jun 2000 01:29:03 +0000
Subject: Re: [Linux-ia64] ia64 gcc implementation of alloca
Message-Id: <marc-linux-ia64-105590678205123@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205122@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205122@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

	Has anyone had any problem using alloca, or knows where in the gcc code it
	is implemented?

There is a lot of GNU code that uses alloca.  I haven't seen any alloca bug
reports.

There are a number of places in gcc that deal with alloca.  The main one
is allocate_dynamic_stack_space in explow.c.

It is probably easier to debug your failing code before trying to debug gcc.
Look at the instruction that failed, disassemble the loose routine, and figure
out why you get the segmentation fault.  It could be a problem with the code
rather than a gcc problem.  Is the stack pointer valid?  Is it aligned
properly, does it point to a valid stack address?

It looks like the program is dying in the dynamic loader when trying to load a
shared library.  Do you have a reasonably up to date copy of the dynamic
loader?  Are your shared libraries up to date?  There were many reports of
problems with glibc failing when a /etc/nsswitch.conf file was present early
this year, but it seems to work fine now.  The Red Hat May 17, 2000 OS release
has the file and it works fine.  I suspect a glibc bug that was fixed maybe a
month or two ago.

Jim


