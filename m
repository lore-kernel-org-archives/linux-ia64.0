From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Wed, 03 Jul 2002 23:33:12 +0000
Subject: [Linux-ia64] pfmon-1.1 w/ Itanium and Itanium2 support is now available
Message-Id: <marc-linux-ia64-105590701905734@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello everyone,

I have now released version 1.1 of the pfmon package. This package
provides access to the kernel support (perfmon) for the IA-64 
Performance Monitoring Unit (PMU).  It includes a generic
library (libpfm) and a tool (pfmon) to monitor unmodified binaries 
or the entire system for both UP and SMP machines. 

This version has full support for BOTH the Itanium and Itanium2 PMU.

This update incorporates many changes and new features in both
the library and the pfmon tool. Here I list only the major pfmon changes:

  - Full support for the Itanium2 PMU. This includes all the advanced
    features:
		* IA-32 execution monitoring
		* event thresholding
		* opcode matching
		* code and data range restrictions including:
			-  fine mode code range
			-  code range inversion
		* Event Address Registers (EAR): 
			- data EAR (cache, TLB, and ALAT)
			- instruction EAR (cache, TLB)
		* Branch Trace Buffer (BTB)

  - Autodetection of host PMU model (single binary for both PMU models)

  - privilege level can be set on a per-event basis (--priv-levels)

  - instruction set can be set on a per-event basis (--insn-sets)

  - regular expression support when listing events (-l)

  - regular expression support when getting event information (-i)

  - session timeout support for both system wide and per-task (-t)

  - printing of counts in various formats (--us-format-counter, --eu-format-counter,...)

  - system wide session can de delimited by the execution of a command

  - can print real,user,system time for the executed command (--show-time)
	
  - support for PMU-model specific sampling output format. Possibility of writing
	  your own format. See (-I, -S, --smpl-output-format).
	  
  - support for symbol tables for both ELF and System.map (--symbol-file, --sysmap-file).
    Wherever an address (--trigger-address) or range (--drange, --irange) is the argument, 
    you can now use a symbol name. A range can be specified with a single symbol or a pair.
    Pfmon will automatically use the symbol table of the command in per-task mode, if it 
    is available.

  - support for a small database (pfmon.conf) of known values (patterns) for opcode matchers.

IMPORTANT: Kernel version restrictions
--------------------------------------

	For both Itanium and Itanium2, you MUST use kernel >= v2.5.18 OR >= v2.4.18.

	For Itanium2 kernels and for both 2.5.x and 2.4.x kernels, you need the Itanium2 (McKinley) 
	PMU description file called perfmon_mckinley.h. This file is available at:

		ftp://ftp.hpl.hp.com/pub/linux-ia64/perfmon_mckinley.h

	You can use the SAME FILE for both kernel trees. Place this file in arch/ia64/kernel
	and recompile with CONFIG_MCKINLEY set.


The new pfmon package is available in TAR format and also in binary RPM from:

		ftp://ftp.hpl.hp.com/pub/linux-ia64/pfmon-1.1.tar.gz
		MD5SUM: 9800e8e40e547c942cb42c7d12e4dc5b

		ftp://ftp.hpl.hp.com/pub/linux-ia64/pfmon-1.1-1.ia64.rpm
		MD5SUM: 1bc0e7a28b1fda76cee69a6662109fbb
	
		ftp://ftp.hpl.hp.com/pub/linux-ia64/pfmon-devel-1.1-1.ia64.rpm
		MD5SUM: e8017d1ba3e778c4aa462d302a085f61

The pfmon-devel package contains what you need to develop your own programs. It also
includes the set of examples. The pfmon package is all you need if you just want to
use the tool. Note that this version of pfmon relies on the libelf package.

NOTE: people who have received early access versions of pfmon-1.1 MUST upgrade to this version
      to get all the latest fixes.

Enjoy,

-- 
-Stephane

