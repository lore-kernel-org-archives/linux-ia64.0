From: Stephane Eranian <eranian@hpl.hp.com>
Date: Tue, 02 Dec 2003 20:32:27 +0000
Subject: pfmon-3.0 is now available
Message-Id: <marc-linux-ia64-107039780814359@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I am happy to report that I have finally released version 3.0 of the pfmon,
a tool to monitor performance on Linux/ia64.

This version represents a major milestone for pfmon. They are many many 
new features to explore, most of them unprecedented on Linux.

Short summary of the new features and changes:
----------------------------------------------
  - full support for Itanium, Itanium2 (all processors in the family)
  - updated to use the kernel perfmon-2 interface
  - complete rewrite of the per-task monitoring support
  - you can now selectively monitor (counting and sampling) across fork(), 
    vfork(), pthread_create() (--follow-fork, --follow-vfork, --follow-pthread, --follow-all)
  - you can follow across several levels of exec() (--follow-exec-*)
  - you can use regular expression to include/exclude certain exec() (--follow-exec, --follow-exec-excl)
  - task execution before and after an exec() can be differentiated (--exec-split)
  - support for code triggers allow you to start and stop monitoring when 
    execution reaches certain locations (--trigger-code-start, --trigger-code-stop)
  - support for data triggers allow you to start and stop monitoring when certain data memory locations
    are accessed (--tigger-data-start, --trigger-data-stop)
  - support for data triggers on read/write/read-write accesses (--trigger-data-ro, --trigger-data-wo)
  - code/data triggers can be repeated (--trigger-code-repeat, --trigger-data-repeat)
  - code/data triggers can follow fork/vfork/pthread_create (--trigger-code-follow, --trigger-data-follow)
  - code stop triggers can be dynamically determined (monitoring limited to execution within a function)
  - you can attach to an already running task (--attach-task)
  - correlation of sample addresses to symbols for the kernel in system-wide mode via /proc/kallsyms (--resolve-addresses)
  - correlation of sample addresses to symbols for task/kernel in per-task mode.
  - you can force a reset of counters not used as sampling periods for each sample (--smpl-reset-non-smpl-periods)
  - you can turn off output of commands that are monitored (--no-cmd-output)
  - support for up to 1024 processors, list specification instead of bitmask (--cpu-list)
  - for experts, possibility to bypass certain event qualifier checks on Itanium and Itanium2 (--no-qual-check)
  - saturation mode when sampling, i.e., only captures the first n samples  (--saturate-smpl-buffer)

REQUIREMENTS:
-------------
	- because pfmon-3.0 is a pure perfmon-2 tool, it CAN ONLY RUN on 2.6.0-test5 kernels or higher. 
	  As several important bugs were fixed recently, I STRONGLY recommend that you download the latest 2.6 
	  kernels from Linus's or David's BK repository.

	- you must have libpfm-3.0 (NOT 3.0-beta) installed (runtime/dev)

	- you must have the libelf or elfutil development package installed

	- given that there is not 2.6-based Linux/ia64 distribution at this point
	  you need to host this on your current distribution and reboot with a 2.6
	  kernel. Pfmon compiles with both LinuxThreads and NPTL thread libraries
	  without Makefile changes.

DOCUMENTATION:
--------------
	The package includes a completely updated documentation which describes
	ALL the features available in pfmon. For each implementation specific
	features (Itanium and Itanium2) there is an additional file.

	The entire documentation is also available online at the perfmon 
	web site at:

		http://www.hpl.hp.com/research/linux/perfmon/

BUG REPORTS:
------------
	Due to limited resources, not all features combinations have necessarily 
	been tested. I have not tested pfmon-3.0 on Itanium (Merced) machines.

	Feel free to test pfmon on your systems and report bugs to me 
	personally or preferrably on the perfmon mailing-list at 
	perfmon@linux.hpl.hp.com (must be a member to post).

DOWNLOADING:
------------
	 pfmon-3.0 source tar file: 
		ftp://ftp.hpl.hp.com/pub/linux-ia64/pfmon-3.0.tar.gz
		MD5SUM: 3f4ea872488ebda2987716d8686981cc

	 pfmon-3.0 binary RPM (RHEL-3.0): 
		ftp://ftp.hpl.hp.com/pub/linux-ia64/pfmon-3.0-1.ia64.rpm
		MD5SUM: 811aafc7280aa6e3be1567ecb6ffa28d

The control files to build the Debian package are included in the source
tar file.

Enjoy,

-- 
-Stephane
