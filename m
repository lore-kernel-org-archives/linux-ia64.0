From: Alex Williamson <awilliam@fc.hp.com>
Date: Fri, 17 Nov 2000 20:12:03 +0000
Subject: [Linux-ia64] ACPI 2.0 support
Message-Id: <marc-linux-ia64-105590678205743@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   I've been working on adding ACPI 2.0 table support for IA-64 in
preparation for McKinley systems.  I have a preliminary version
that correctly parses 2.0 tables on an architectural simulator.
I'd also like to get Intel's drop of the ACPI CA w/ 2.0 support
added into the kernel as quickly as possible.  Is there a
current maintainer of IA-64 ACPI support?  Is there anyone else
interested in working on this or testing it?

   I'd also like to incorporate using ACPI methods to get resource
information for programming PCI devices, eventually leading to
support for hot-plug PCI via ACPI.  Anyone have any thoughts or
interest there?  Thanks,

	Alex

--
Alex Williamson                                  Linux Development Lab
awilliam@fc.hp.com                                     Hewlett Packard
970-898-9173                                          Fort Collins, CO

