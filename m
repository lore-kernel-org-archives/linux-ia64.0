From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Tue, 26 Feb 2002 00:13:54 +0000
Subject: [Linux-ia64] minor update to gnu-efi package available
Message-Id: <marc-linux-ia64-105590701905191@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

We have recently uncovered a problem with the gnu-efi package version 3.0
and versions of gcc > 3.0 such as the one shipped on Redhat7.2/ia64. 

The problem is caused by some new optimization in the code generating 
the read-only data sections. Basically, the constant strings (such as for
printf()) are moved into a section that is not called .rodata anymore but
.rodata.strX.Y (where X and Y can vary). The loader scripts did not
know about these sections and therefore were not including them resulting
in garbage being printed by the Print() function.

Version 3.0a of gnu-efi corrects this problem on both IA-32 and IA-64 
systems. There was no other important changes to the package.

You can download the package at:

		ftp://ftp.hpl.hp.com/pub/linux-ia64/gnu-efi-3.0a.tar.gz


+--------------------------------------------------------------------+
| Ste'phane ERANIAN                       | Email eranian@hpl.hp.com |
| Hewlett-Packard Laboratories            |                          |
| 1501, Page Mill Road MS 1U-15           |                          |
| Palo  Alto, CA 94303-096                |                          |
| USA                                     |                          |
| Tel : (650) 857-7174                    |                          |
| Fax : (650) 857-5548                    |                          |
+--------------------------------------------------------------------+

