From: Stephane Eranian <eranian@hpl.hp.com>
Date: Mon, 01 Dec 2003 23:59:51 +0000
Subject: libpfm-3.0 is now available
Message-Id: <marc-linux-ia64-107032375205623@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello all,

I have finally released  version 3.0 of libpfm, a helper library
for monitoring tools using the IA-64 PMU hardware.

This new version includes many bug fixes, changes and cleanups. It is NOT 
backward compatible with libpfm-2.0. There are a few important interface 
changes which make it impossible to just recompile your applications, you need 
to adjust your source code. The changes are not drastic and the library comes 
with a extended set of examples showing how to use the new interface for all sorts 
of measurements.

This new version of the library is meant to be used with the 2.6 kernel series ONLY. 
Even though the core of the library is NOW totally independent of the kernel
interface you are using, the libpfm package comes with the kernel header files 
necessary to access the new Linux/ia64 perfmon-2 subsystem. All the examples have 
also been updated to use the kernel perfmon-2 interface.  The perfmon-2 interface is 
not backward compatible with perfmon-1 found on all 2.4-based kernels.

This version of the library supports Itanium, Itanium2 (McKinley, Madison, Deerfield, DP) 
and also a generic IA-64 CPU model.

Make sure you take a look at the README for information about the package.

The entire documentation along with some examples will shortly be made 
available online on the perfmon web site at:

	http://www.hpl.hp.com/research/linux/perfmon


You can download the library in source code or binary RPMs at:

	ftp://ftp.hpl.hp.com/pub/linux-ia64/libpfm-3.0.tar.gz
	MD5SUM: a30e16596202391256efe1e3a45058d5

	ftp://ftp.hpl.hp.com/pub/linux-ia64/libpfm-3.0-1.ia64.rpm
	MD5SUM: 3d984f6ca64506ff1a8e27352982cff5

	ftp://ftp.hpl.hp.com/pub/linux-ia64/libpfm-devel-3.0-1.ia64.rpm
	MD5SUM: dc4b3a80b446e7420a119a157b384feb

If you need the library to run other packages such as pfmon, then you 
only need the runtime RPM package (libpfm-3.0-1.ia64.rpm). For developments,
you need the other package (libpfm-devel-3.0-1.ia64.rpm) AS WELL.

The control files to build the Debian packages are included in the tar file.

Enjoy,

PS: The library is required by pfmon-3.0 to be released very soon now.
-- 

-Stephane
