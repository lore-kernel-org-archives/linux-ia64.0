From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 31 May 2003 00:03:09 +0000
Subject: [Linux-ia64] fsyscall infrastructure finished (hopefully... ;-)
Message-Id: <marc-linux-ia64-105590723706094@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Now that there is a streamlined syscall path (thanks to Rohit,
Fenghua, & Asit's work), it was time to finish the fsyscall
infrastructure such that it avoids using the "break" instruction when
entering the kernel.  I just pushed the necessary code into the
linux-ia64-2.5 tree.

The net result is that epc-based stubs are now always faster, even if
there is no light-weight systemcall handler.  In a nut-shell:

 - null system call with break-based stub:		285 cycles
 - null system call with epc-based stub (fsyscall):	266 cycles
 - null system call with light-weight handler:		 50 cycles

 - gettimeofday with break-based stub:			491 cycles
 - gettimeofday with epc-based stub (fsyscall):		466 cycles
 - gettimeofday with light-weight handler:		136 cycles

Relative to older kernels:
						original w/Rohit's  current
						2.5.69   patch	    2.5.69

 - null system call with break-based stub:	338 cyc  282 cyc    285 cyc
 - null system call with light-weight handler:	 49 cyc    n/a       50 cyc
 - gettimeofday with break-based stub:		544 cyc  491 cyc    491 cyc
 - gettimeofday with light-weight handler:	130 cyc    n/a      136 cyc

So, by and large, the final version should be as good or substantially
better than what was there before.

I'm quite certain there is more tuning that could be done in the
syscall path, but what's there now is reasonably straightforward and
performs rather well.  A nice thing about the current setup is that
syscall restart works _exactly_ the same, independent of whether the
(heavy-weight) system call was entered via break or via epc.  This
saves a substantial amount of complexity.

I also added a new boot command line option.  If you boot with
"nolwsys", then the kernel won't be using light-weight system-call
handlers at all.  This is primarily useful for performance
measurements, but the code to support it is so trivial that I left it
in there.

Caveat: the current linux-ia64-2.5 breaks execve to ia32 tasks. It'll
get fixed some day.  In the meantime, sorry about that.

Enjoy,

	--david

