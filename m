From: "Mallick, Asit K" <asit.k.mallick@intel.com>
Date: Fri, 17 Nov 2000 20:34:31 +0000
Subject: RE: [Linux-ia64] ACPI 2.0 support
Message-Id: <marc-linux-ia64-105590678205744@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205743@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205743@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Intel has done the ACPI 2.0 table parsing and testing with FWs that support
ACPI 2.0 tables. We are planning to integrate this code in the next release.
These works are done primarily in preparation for McKinley systems.

Thanks,
Asit


> -----Original Message-----
> From: Alex Williamson [mailto:awilliam@fc.hp.com]
> Sent: Friday, November 17, 2000 12:12 PM
> To: linux-ia64@linuxia64.org
> Subject: [Linux-ia64] ACPI 2.0 support
> 
> 
> 
>    I've been working on adding ACPI 2.0 table support for IA-64 in
> preparation for McKinley systems.  I have a preliminary version
> that correctly parses 2.0 tables on an architectural simulator.
> I'd also like to get Intel's drop of the ACPI CA w/ 2.0 support
> added into the kernel as quickly as possible.  Is there a
> current maintainer of IA-64 ACPI support?  Is there anyone else
> interested in working on this or testing it?
> 
>    I'd also like to incorporate using ACPI methods to get resource
> information for programming PCI devices, eventually leading to
> support for hot-plug PCI via ACPI.  Anyone have any thoughts or
> interest there?  Thanks,
> 
> 	Alex
> 
> --
> Alex Williamson                                  Linux Development Lab
> awilliam@fc.hp.com                                     Hewlett Packard
> 970-898-9173                                          Fort Collins, CO
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 


