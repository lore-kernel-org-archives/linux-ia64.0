From: Stephane Eranian <eranian@hpl.hp.com>
Date: Wed, 05 Apr 2006 15:43:19 +0000
Subject: 2.6.17-rc1 perfmon2 new code base + libpfm available
Message-Id: <20060405154319.GD6232@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: perfmon@napali.hpl.hp.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, oprofile-list@lists.sourceforge.net, perfctr-devel@lists.sourceforge.net

Hello,

I have released another version of the perfmon new code base package.
This release is relative to 2.6.17-rc1

There were, once again, new system calls added. As such a new libpfm is
necessary.

This new kernel patch includes several changes:

	- Merged i386 and x86_64 perfmon.c architecture specific codes

	- Merged PMU description modules for em64t and p4.

	- support for automatic loading of PMU description modules if
	  CONFIG_KMOD=y. Make sure you run make modules_install

	- MIPS patches are back and are applied onto the mainline kernel

This release uses the new/mod patch breakdown for all architectures.
To apply, you can simply do:
	cat ../perfmon-new-base-060405/*.diff | patch -p1 

The new version of the library, libpfm, includes the following changes:

	- updated to match 2.6.17-rc1 new system call numbers

	- modified pfmlib.h to use 64-bit integer for generic PMC register
	  (submitted by Kevin Corry from IBM)

I have finally created a minimal home page for the project. So now
you can access the latest news and files from:

	http://perfmon2.sf.net

I received notification from SF.net, that the libpfm package has been installed
into our CVS repository. It should become visible fairly quickly now. Once this
happens, I will update the tree to include this new version of the library.

Enjoy,

-- 
-Stephane
