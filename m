From: "Moore, Robert" <robert.moore@intel.com>
Date: Fri, 16 Sep 2005 21:56:31 +0000
Subject: RE: [ACPI] [PATCH] ACPI: implement UUID-labelled vendor-defined resources
Message-Id: <971FCB6690CD0E4898387DBF7552B90E02C0B5F2@orsmsx403.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200506211421.20446.bjorn.helgaas@hp.com>
In-Reply-To: <200506211421.20446.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>, "Brown, Len" <len.brown@intel.com>
Cc: Alex Williamson <alex.williamson@hp.com>, acpi-devel@lists.sourceforge.net, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org

And to make things even more interesting, the base ACPICA code looks
nothing like the final Linux version of the code; it is converted on the
fly before every release to Linux.

BTW, Please explain in more detail what support is needed in ACPICA for
the ACPI 3.0 vendor-defined resource.  Also, any idea how we are
supposed to determine if the UUID data exists within the descriptor?
(i.e., how do we differentiate an ACPI 2.0 vendor descriptor from an
ACPI 3.0 descriptor?)

Thanks,
Bob


> -----Original Message-----
> From: acpi-devel-admin@lists.sourceforge.net [mailto:acpi-devel-
> admin@lists.sourceforge.net] On Behalf Of Bjorn Helgaas
> Sent: Friday, September 16, 2005 10:41 AM
> To: Brown, Len
> Cc: Alex Williamson; acpi-devel@lists.sourceforge.net; Luck, Tony;
linux-
> ia64@vger.kernel.org
> Subject: [ACPI] [PATCH] ACPI: implement UUID-labelled vendor-defined
> resources
> 
> ACPI 3.0 includes UUID-labelled vendor-defined resources (section
> 6.4.3.2),
> so move the code that supports this from arch/ia64 into ACPI proper.
> 
> Len, Tony, this touches both acpi and ia64.  Probably easiest
> if Tony acks it and Len decides whether to apply it.
> 
> HP owns all the copyrights on the code being moved, and we agree
> that the code being moved into the ACPI CA may be used under either
> the GPL or the BSD-style license used by the ACPI CA.
> 
> (There should be something in Documentation/acpi about how to
> contribute to the ACPI CA.  It's a royal pain in the rear :-)).
> 

