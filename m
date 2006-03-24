From: Stephane Eranian <eranian@hpl.hp.com>
Date: Fri, 24 Mar 2006 09:34:27 +0000
Subject: gnu-efi-3.0c is available
Message-Id: <20060324093427.GC28939@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, nigel.croxon@hp.com

Hello,

I have released a new version of the GNU-EFI package.
This package is used to build EFI applications on Linux
for both IA-32 and IA-64 architectures.

This is a maintenance release with no new features just
updates to support the latest GNU compilers:

	- updated linker scripts to support latest gcc sections.
	  Provided by H.J. Lu from Intel. Special thanks to Jim Wilson
	  for his help.

	- updated library to compile cleanly with gcc4.1.
	  Provided by Raymund Will from SuSE

I have tested the package on Linux/ia64 with Debian gcc-4.0.3
and binutils 2.16.91. With this, you can build a working elilo3.6.

It compiles on Debian/i386 with gcc 4.0.3 and binutils 2.6.91.
I dot have the setup to test i386 efi
binaries.

You can grab the package at:
	ftp://ftp.hpl.hp.com/pub/linux-ia64/gnu-efi-3.0c.tar.gz
	MD5SUM: 823e5f04d1c0a7b88831f91fbf12d470

This is the last gnu-efi release that I manage. I am handing over
the maintenance of the package to Nigel Croxon from HP. Please forward
any new questions to him from now on. He is copied on this announcement.

Thanks.

-- 
-Stephane
