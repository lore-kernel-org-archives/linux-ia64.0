From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 09 Jan 2001 19:23:23 +0000
Subject: [Linux-ia64] IA-64 Linux TODO list
Message-Id: <marc-linux-ia64-105590678205896@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Since we're getting closer to a real release of various IA-64 Linux
distros, I thought it would be a good idea to pass around my TODO
list.  I'd really appreciate if someone else could maintain this list
and mail it out periodically (weekly?) as my bw is pretty limited
right now.  Here is what comes to mind:

Kernel
 - enable kernel unaligned handler
 - verify that all on-board hardware is supported and working:
	- does cs4281 sound driver work reliably now?
	- what to do about eepro100? (currently hangs on > 180MB transfers?)
 - investigate and fix test suite failures reported by SCO (Who's the
   contact person at SCO for this?  Please make available simple test
   cases that reproduce the problem so we can go about fixing them.)
 - consider clearing CPU state on an execve() to avoid leaking information
   to a new program; Alan Cox thinks it would be sufficient to do this
   when current->dumpable is zero

Libraries
 - gprof support?

Apps
 - gdb
    - NaT bits don't seem to work properly?
    - coredump support still broken?
 - strace
    - 'strace -f' hangs if the program forks a child;
    - verify that the new system calls have been added

I'm planning to work on the kernel unaligned handler but if someone
else is dying on doing that, let me know. ;-)

If you can think of anything else, please let me know---I'll try keep
the list uptodate for now.

	--david

