From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Wed, 29 Jun 2005 04:20:45 +0000
Subject: Fast Syscalls and Virtualised Linux on Linux
Message-Id: <17090.8605.481641.322881@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi,
	I'm working on a user-mode-linux like thing for IA64.  I have
something working. but performance is awful.  The reason is
syscall-via-break.

When a process running in the guest OS calls a system call via break
(or a system call is restarted, and so falls back to syscall via
break) the host OS catches it and tries to execute the system call.
This is obviously undesireable.

The trick I'm using at present (not my own, Matt Chapman implemented
it) is to ptrace the Virtual Machine Monitor, catch all system calls,
and redirect ones that are for the guest OS to the guest.

Obviously, when a process running under the guest uses the fast system
call path, the host doesn't see it, and so it can run at full speed.
But there are enough cases where things fall back to the old via-break
path that the ptrace hack is still needed.  And because it intercepts
*every* system call even virtualised operations like read/write to the
virtual disks cop the overhead.

One approach might be to redefine __BREAK_SYSCALL for the guest OS.
That'd require a specially compiled glibc and kernel, and possibly
other executables.

Does anyone have a better idea?


-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
