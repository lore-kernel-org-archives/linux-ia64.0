From: Stephane Eranian <eranian@hpl.hp.com>
Date: Fri, 12 May 2006 15:15:37 +0000
Subject: 2.6.17-rc4 new perfmon code base + libpfm available
Message-Id: <20060512151537.GA26310@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: perfmon@napali.hpl.hp.com
Cc: linux-ia64@vger.kernel.org, perfctr-devel@lists.sourceforge.net, oprofile-list@lists.sourceforge.net, linux-kernel@vger.kernel.org

Hello,

I have released another version of the perfmon new code base package.
This release is relative to 2.6.17-rc4

There were, once again, new system calls added. As such a new libpfm is
necessary.

This new kernel patch includes a few changes:

	- Merged P6 and Pentium M processors PMU description tables.
	  perfmon_pm.c is mergde into perfmon_p6.c

	- change system call number for all architectures.

This release uses the new/mod patch breakdown for all architectures.
To apply, you can simply do:
	cat ../perfmon-new-base-060512/*.diff | patch -p1 

The new version of the library, libpfm, includes the following changes:

	- updated to match 2.6.17-rc4 new system call numbers

	- enhancement to MIPS support (Phil Mucci)

	- modified internal get_event_code() to get_event_code_counter()
	  to accomodate PMU where an event code depends on the counter where
	  it is programmed.

	- enhanced P6 CPU detection

	- preliminary support for the IA-32 architected PMU as described
	  in the latest version of the IA-32 architecture manuals. You need
	  a Core Duo/Solo processor for this to work. Note that the architected
	  PMU for those models only gives access to a subset of the features.

I do not have a Core Duo machine myself so I could not actually test this code.
I would appreciate if somebody could test the libpfm examples on such machine and
report back to me. I am glad to see that IA-32 finally has the beginning of an
architected PMU.

You can grab the new packages at our web site: http://perfmon2.sf.net

It looks like SF.net is close to fixing the CVS outage. When that happens I will be
able to populate the repository for both libpfm and pfmon.

I will post a clear text patch to lkml shortly.

Enjoy,

-- 
-Stephane
