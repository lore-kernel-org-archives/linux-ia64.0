From: "Grover, Andrew" <andrew.grover@intel.com>
Date: Tue, 04 Jun 2002 17:13:43 +0000
Subject: RE: [Linux-ia64] Question about wbinvd
Message-Id: <marc-linux-ia64-105590701905637@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905635@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905635@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> From: Matthew Wilcox [mailto:willy@debian.org] 
> If you look at the latest ACPI patch (20020517), you will see:
> 
> -       wbinvd();
> +       ACPI_FLUSH_CPU_CACHE ();
> 
> On i386, ACPI_FLUSH_CPU_CACHE is defined to be wbinvd, but on 
> ia64 it is
> defined to be a no-op.  So the wbinvd in the ACPI code is no 
> longer used.
> I presume it was decided it is not necessary.

I don't know if it is not necessary or not. We changed it because "wbinvd"
is a IA32-ism. IA64 may need to define ACPI_FLUSH_CPU_CACHE to something
appropriate.

Regards -- Andy

