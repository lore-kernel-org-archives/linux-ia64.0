From: Don Dugger <n0ano@valinux.com>
Date: Fri, 09 Feb 2001 17:58:58 +0000
Subject: [Linux-ia64] TODO list
Message-Id: <marc-linux-ia64-105590693005124@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

All-

As promised, here is the Linux IA64 To-Do list, current
as of 2/9/01.  The pretty printed HTML version is always
available at `http://www.linuxia64.org/todo.html/'.  Note
that there are a few things that no one has signed up to
do yet.  If you are interested in taking responsibility for:

	EEPro100
	Hot plug SCSI
	GLIBC unwind API
	setjmp cleanup

just let me know (here is your chance for fame and fortune :-)




Linux IA64 To-Do List
Februrary 9, 2001

Kernel

	Task
	  Owner
	    Details 

	Unaligned handler
	  David Mosberger - DONE
	    Works for user procs, need support for kernel
	

	CS4281 Sound
	  Thomas Woller
	    Should be OK, requires updated MPG128 and/or XMMS
	

	EEPro100
	  ?
	    Hangs on >180MB xfers
	

	Hot plug SCSI
	  ?
	    Hotplugging doesn't crash the kernel but the
	    kernel doesn't detect the change.
	

	Other HW Support
	

	UNIX98 test suite
	  Doug Beattie
	    Fix test suite failures, need simple test cases
	

	CPU state on execve
	  David Mosberger
	    Clear CPU state to avoid info leak to new program.
	    Alan Cox thinks it would be sufficient to do this when
	    current->dumpable is zero

	AGP Support
	    Chris Ahna
	

	DRI support
	  Chris Ahna
	    Need DRI module for ATI Rage128
	

	llseek
	  Erich Focht - DONE
	    Need llseek for fs/proc/base.c:proc_mem operations.
	    Patch submitted.
	


Libraries


	Task
	  Owner
	    Details
	

	gprof support
	  Jes Sorensen
	    Most of the GLIBC bits should be there,
	    hope to get the M4 autoconf done soon.
	

	GLIBC unwind API
	  ?  
	    Define API that works with signal handling, probably
		starting from the kernel unwinder.
	    Implement this API
	    Contact David Mosberger for details.
		
	

	setjmp cleanup
	  ?  
	    Bring setjmp into compliance with SW conventions
	      (flushrs must be done on a setjmp)
	    Remove extraneous loadrs in __longjmp.
	    Contact David Mosberger for details.
		
	


Applications


	Task Owner Details
	

	gdb
	  Kevin Buettner 
	    NaT bits fail
	    pthread support
	    coredump support broken
	    inferior function calls fail
	    HW watchpoints fail
	

	strace
	  Don Dugger 
	    new system calls added
	    strace -f hangs on a fork
-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@valinux.com
Ph: 303/938-9838

