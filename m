From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Thu, 12 Oct 2000 20:45:19 +0000
Subject: [Linux-ia64] gnu-efi-1.0 available
Message-Id: <marc-linux-ia64-105590678205566@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi All,

I have uploaded a new version of the gnu-efi package on our FTP site.

Highlights of version 1.0 are:

	- ability to create bigger binaries (David Mosberger)

	- LILO: ability to load a FPSWA driver from a file if necessary
	- LILO: some bug fixes and cleanups of error messages.
	- LILO: put in a workaround to avoid the LoadOptionSize problem.

Note: This version of LILO still has some ACPI code. With firmware 60 and
higher this is not required as the kernel does the processing to extract
the information. So I expect to get rid of this support soon.


This new version is available at:

	ftp://ftp.hpl.hp.com/pub/linux-ia64/gnu-efi-1.0.tgz


+--------------------------------------------------------------------+
| Ste'phane ERANIAN                       | Email eranian@hpl.hp.com |
| Hewlett-Packard Laboratories            |                          |
| 1501, Page Mill Road MS 1U-15           |                          |
| Palo  Alto, CA 94303-096                |                          |
| USA                                     |                          |
| Tel : (650) 857-7174                    |                          |
| Fax : (650) 857-5548                    |                          |
+--------------------------------------------------------------------+


