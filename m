From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Thu, 05 Dec 2002 20:28:40 +0000
Subject: [Linux-ia64] Beta version of pfmon-2.0 available for testing
Message-Id: <marc-linux-ia64-105590709805507@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello everyone,

I have made available for TESTING/REVIEW a beta of version 2.0 of the pfmon 
PMU-based monitoring tool for Linux/ia64. Depending on the feedback, I should
release final version on Monday Dec 16th.

There is no major overhaul of the tool despite the new major version 
number. This changes is dictated by the fact that the library (libpfm)
on which pfmon is based is now a separate package called libpfm. The 
licence of the library was changed from GPL to MIT-style licence to allow
more diverse use (see http://www.opensource.org for details).

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
		
	2/ libpfm
		- changed pfmlib_param_t structure to include the pfarg_reg_t table.

		- changed interface to pfm_dispatch_events().

		- man pages for all possible calls, generic and model specific.

		- simplified pfm_find_*() interface

		- support for shared version of the library.

		- a lot of bug fixes and code cleanups.

Thanks to the UIUC Impact Compiler Team, David Mosberger, Elias Mizan, and Dan Magenheimer
for submitting bug reports and patches.

IMPORTANT NOTES:
----------------
- Randomization requires kernel support. You need the upcoming 2.4.20 or 2.5.39 (or higher)
  for this to work.

- Due to the interface change in the library, existing applications need to be updated.
  Follow documentation and look at the code examples in the library package.

The preliminary packages are available in full source tarball and RPM formats from:

		ftp://ftp.hpl.hp.com/pub/linux-ia64/pfmon-2.0.tar.gz
		MD5SUM: 361e5a882c35555644ea15bcf90ca3ee

		ftp://ftp.hpl.hp.com/pub/linux-ia64/pfmon-2.0-1.ia64.rpm
		MD5SUM: 93db4e84ee00951eb53b22985e77b640
	
		ftp://ftp.hpl.hp.com/pub/linux-ia64/libpfm-2.0.tar.gz
		MD5SUM: c8fc6826c53eb315a0e95b26e413db62

		ftp://ftp.hpl.hp.com/pub/linux-ia64/libpfm-2.0-1.ia64.rpm
		MD5SUM: b4d48e728e4c8cc9d145cd72b4b84385

		ftp://ftp.hpl.hp.com/pub/linux-ia64/libpfm-devel-2.0-1.ia64.rpm
		MD5SUM: 55ab9766a42b5115d65e73b1e05a80a9

Enjoy,

-- 
-Stephane

