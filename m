From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Mon, 06 Jan 2003 19:22:23 +0000
Subject: [Linux-ia64] pfmon-2.0/libpfm-2.0 final packages are now available
Message-Id: <marc-linux-ia64-105590709805637@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello everyone,

Let's start the new year with some new software!

I have now released the *FINAL* bits of version 2.0 of the pfmon 
PMU-based monitoring tool for Linux/ia64.

There is no major overhaul compared with version 1.1 of the tool despite 
the new major version number. This change is dictated by the fact that the 
library (libpfm) on which pfmon is based is now a separate package called 
libpfm. 

The licence of the library was changed from GPL to MIT-style licence to allow
more diverse use (see http://www.opensource.org for details).

IMPORTANT: If you have downloaded the beta version of pfmon 2.0 or libpfm 2.0, 
           please UPGRADE to the official final version as some changes/bug 
           fixes were made.

Highlights of the changes:
--------------------------

  1/ pfmon

	- support for sampling period randomization. The mechanisms
	  uses a bitmask and a seed per counters. The random sequence
	  is fully determined by the seed, allowing identical reruns
	  (--smpl-periods-randomize).

	- support for monitoring at privilege level 1 & 2 (-1, -2).

	- a new option to activate monitoring after a certain number 
	  of seconds (--trigger-start-delay).

	- a lot of bug fixes related to Itanium2 (BTB) and sampling.

	- a lot of code cleanup and simplifications.

	- more checking on event combinations.

	- updated documentation (see in docs).

	- a new --exclude-idle option to exclude idle task execution
	  from system wide sessions. This REQUIRES kernel perfmon-1.3, 
          which has NOT YET been released.
		
  2/ libpfm

	- changed interface to pfm_dispatch_events().

	- changed pfmlib_param_t structure to include the pfarg_reg_t 
          table.

	- man pages for all possible calls, generic and model specific.

	- simplified pfm_find_*() interface

	- support for shared version of the library.

	- a lot of bug fixes and code cleanups.

Thanks to the UIUC Impact Compiler Team, David Mosberger, Elias Mizan, 
Peter Chubb and Dan Magenheimer for submitting bug reports and patches.


NOTES:
------

  - Randomization requires kernel support. You need 2.4.20 or 2.5.39 (or higher)
    for this to work.

  - Due to the interface change in the library, existing applications need to be 
    updated. Follow the documentation and look at the code examples in the 
    library package.

  - Idle task exclusion requires kernel support. The required support will be
    added to the upcoming kernel perfmon-1.3 version and will show up the in
    next release of the 2.4 and 2.5 kernel series.

DOWNLOADS:
----------
The packages are available in full source tarball and RPM formats from:

	ftp://ftp.hpl.hp.com/pub/linux-ia64/pfmon-2.0.tar.gz
	MD5SUM: 9ad0abe5abc3101b5f380ef6d5722c99

	ftp://ftp.hpl.hp.com/pub/linux-ia64/pfmon-2.0-1.ia64.rpm
	MD5SUM: 890ddacf12de80d496ad27b42d06040d
	
	ftp://ftp.hpl.hp.com/pub/linux-ia64/libpfm-2.0.tar.gz
	MD5SUM: 04698ba3a71f3a641db05269596b5913

	ftp://ftp.hpl.hp.com/pub/linux-ia64/libpfm-2.0-1.ia64.rpm
	MD5SUM: 7432050a5c2855bb74989942f2dae782

	ftp://ftp.hpl.hp.com/pub/linux-ia64/libpfm-devel-2.0-1.ia64.rpm
	MD5SUM: a433a9b4df3fed1f815f99a016917264

Enjoy,

Happy new Year.

-- 
-Stephane

