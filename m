From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Mon, 11 Feb 2002 23:52:55 +0000
Subject: [Linux-ia64] pfmon-1.0 released!
Message-Id: <marc-linux-ia64-105590698806035@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I have now released version 1.0 of the pfmon package. This package
provides access to the kernel support (perfmon) for the IA-64 
Performance Monitoring Unit (PMU).  The package includes a generic
library (libpfm) and a tool to monitor standalone programs or the
entire system. This version has full support for the Itanium PMU
but also includes support for the default architected PMU. I will
release the McKinley code once the specifications have been made
public.

This major update incorporates many changes and new features:

	1/ For the pfmon tool:

	  * Common to all CPU models:
          (new)	- completely restructured code: ready for new CPU models
          (new)	- support for system wide monitoring for BOTH UP and SMP systems
          (new)	- delayed monitoring start 
          (new)	- sampling on all events (not just Itanium EAR/BTB)
          (new)	- new sampling output formats: raw, compact, normal
          (new)	- result aggregation (for SMP system wide monitoring)
          (new)	- support for generic IA-64 PMU (architected PMU): pfmon_gen
          (new)	- a thousand-line user's guide

	  * Itanium specific features:	
		- event thresholds support
	  (new)	- support for the renamed Itanium events
		- Event Address Registers (EARS) support
		- Branch Trace Buffer (BTB)
		- opcode matchers
  	  (new)	- code and data range restrictions
	  (new) - IA-32 code monitoring
	
 	2/ For the library (libpfm):

	  (new)	- completely restructured code: ready for new CPU models
	  (new)	- added support for Itanium range restriction feature

	3/ Examples

	   (new) - A new set of examples showing how the library and kernel interfaces
	   	   can be used. This includes, how to sample, monitor undmodifed programs,
		   create a system wide session, and so on.

IMPORTANT: You must have at least
		- kernel >= v2.5.3
		- kernel >= v.2.4.18 (not yet released)

	   This version of pfmon DOES NOT WORK on ANY older kernel. Similarly, 
	   pfmon-0.06 or 0.06a DO NOT WORK on 2.5.3 or 2.4.18.


The package is available in TAR format and also in binary RPM. You can get the package at:

		ftp://ftp.hpl.hp.com/pub/linux-ia64/pfmon-1.0.tar.gz
		ftp://ftp.hpl.hp.com/pub/linux-ia64/pfmon-1.0-1.ia64.rpm
		ftp://ftp.hpl.hp.com/pub/linux-ia64/pfmon-devel-1.0-1.ia64.rpm

The pfmon-devel package contains what you need to develop your own programs. It also
includes the set of examples. The pfmon package is all you need if you just want to
use the tool.

Enjoy,

-- 
-Stephane

