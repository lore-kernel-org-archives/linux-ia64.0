From: Jeff Dike <jdike@karaya.com>
Date: Tue, 06 Jun 2000 05:08:06 +0000
Subject: [Linux-ia64] ptrace and system call interception
Message-Id: <marc-linux-ia64-105590678205120@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm looking into porting the user-mode kernel port (see 
http://user-mode-linux.sourceforge.net) to IA64.  This depends heavily on 
ptrace's system call interception and modification abilities.

I need to be able to annull system calls by changing the system call number (I 
use __NR_getpid).  My reading of entry.S, and running some test code, says 
that this doesn't work.  Can this be added without too much difficulty?  If 
so, can sourceforge (or intel - whoever owns the protos available through 
sourceforge) be persuaded to update without too much difficulty :-)

Another thing that's not obvious is where the system call arguments are 
stored.  I can locate the system call number (PT_R15) and its return value 
(PT_R8) without too much difficulty, but I don't see the arguments.

				Thanks, Jeff




