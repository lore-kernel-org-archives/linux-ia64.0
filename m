From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Thu, 28 Feb 2002 01:28:59 +0000
Subject: [Linux-ia64] summary of perfmon changes in 2.4.18/2.5.3
Message-Id: <marc-linux-ia64-105590701905195@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Here is a short summary of the changes you will find in the perfmon 
code with kernel version 2.4.18 and also 2.5.3 or higher.

--------------------------------------------------------------------
IMPORTANT: This version is not compatible with the previous version
of perfmon. All the applications must be updated, recompiling won't
be enough.
--------------------------------------------------------------------

	- full 64-birt interface for counters: you don't get notifications
	  unless the 64-bit value of the counter overflows, even if the
	  underlying PMU uses narrower counters. The user only programs
	  64-bit values.

	- the perfmonctl() system call has dropped the flags argument.

	- the command specific argument (3rd parameters) is using a different
	  struct for each command (when needed). The union has been been
	  dropped to allow better portability across versions.

	- support for sampling on any events, not just the the Itanium
	  EAR/BTB.

	- possibility to indicate a set of PMD registers to reset when a 
	  counter overflows.

	- the two sampling values have been clarified: long_reset and short_reset.

	- lots of code cleanups. Minimal CPU-model specific code. We are
	  almost ready for McKinley.

	- added interface to program the debug registers for performance 
	  monitoring when support by the PMU (PFM_WRITE_DBRS, PFM_WRITE_IBRS). 
	  On Itanium this is used to implement code & data address range 
	  restrictions.

	- added support for system wide monitoring for both UP and SMP
	  systems. SMP is obtained via process pinning to keep the kernel
	  code as simple as possible. The pinning interface is part of
	  the perfmon interface until the kernel provides a better solution.

	- lots of performance improvments for the context swich code for
	  per-process monitoring < 2% overhead with four counters.

	- for per-process monitoring the kernel now enforces the use of
	  user monitors (pmc.pm=0).

	- for system-wide monitoring the kernel now enforces the use of
	  privileged monitors (pmc.pm=1).

	- introduction of PFM_PROTECT_CONTEXT command to forbid access to
	  the context by a process that is not its creator. This is useful
	  for per-process sessions on unmodified (possible malicious) binaries.

There were a lot of smaller changes which are not captured here. So please
refer to the source code for more information or E-mail me. 

Version 1.0 of the pfmon package has support for this new interface and the
libpfm library and pfmon tool do provide the additional feature, such
as address range restriction on Itanium and system wide monitoring.
The pfmon package now includes a wide range of example demonstrating 
how the interface can be used to collect counts and sampling traces.
You can download this package from:

		ftp://ftp.hpl.hp.com/pub/linux-ia64/pfmon-1.0.tar.gz

I will publish a detailed document describing the perfmon interface in the
coming weeks.

Enjoy,

+--------------------------------------------------------------------+
| Ste'phane ERANIAN                       | Email eranian@hpl.hp.com |
| Hewlett-Packard Laboratories            |                          |
| 1501, Page Mill Road MS 1U-15           |                          |
| Palo  Alto, CA 94303-096                |                          |
| USA                                     |                          |
| Tel : (650) 857-7174                    |                          |
| Fax : (650) 857-5548                    |                          |
+--------------------------------------------------------------------+

