From: Keith Owens <kaos@ocs.com.au>
Date: Mon, 06 Nov 2000 05:47:34 +0000
Subject: [Linux-ia64] Announce: ksymoops 2.3.5 is available
Message-Id: <marc-linux-ia64-105590678205656@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Mirror at ftp://ftp.**.kernel.org/pub/linux/utils/kernel/ksymoops/v2.3
           replace '**' with your favourite local kernel.org mirror.

ksymoops-2.3.5.tar.gz		Source tarball, includes RPM spec file
ksymoops-2.3.5-1.src.rpm	As above, in SRPM format
ksymoops-2.3.5-1.i386.rpm	Compiled with egcs-2.91.66, glibc 2.1.2
patch-ksymoops-2.3.5.gz		Patch from 2.3.4.

Changelog extract

	* Handle SGI kdb initial report.
	* Static link against libbfd, libiberty to stop version problems.
	  Suggested by HJ Lu.
	* Add BUG to printed text.
	* Add wait_on_irq lines to printed text.
	* Handle weak references that have been resolved.
	* Support for IA64.
	* Add mandir to spec file.

	Ross Patterson <Ross.Patterson@CA.Com>
 	* Recognize s390 kernel PSW and registers.
 	* Don't try to decode s390 user PSW and registers.
 	* Set default target and architecture on recognition of i370 or s390
 	  kernel PSW (ala Oops_set_eip()).


