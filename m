From: "Moore, Robert" <robert.moore@intel.com>
Date: Fri, 10 Feb 2006 21:19:23 +0000
Subject: RE: some new unaligned access while booting ia64 (HP rx2620)
Message-Id: <971FCB6690CD0E4898387DBF7552B90E0452ADF8@orsmsx403.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200602021946.k12Jk446028921@agluck-lia64.sc.intel.com>
In-Reply-To: <200602021946.k12Jk446028921@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>, Thomas Renninger <trenn@suse.de>, "Brown, Len" <len.brown@intel.com>
Cc: linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org

Yes, In linux everything gets converted to lower case, sorry.

The debug trace mechanism is known to work, I hope it isn't broken on
IA64. 

Does any debug info come out?

Bob


> -----Original Message-----
> From: Luck, Tony
> Sent: Friday, February 10, 2006 1:16 PM
> To: Moore, Robert; 'Thomas Renninger'
> Cc: 'linux-acpi@vger.kernel.org'; 'linux-ia64@vger.kernel.org'
> Subject: RE: some new unaligned access while booting ia64 (HP rx2620)
> 
> > Enabling debugging in the ACPI subsystem will certainly give this
> > information. AcpiDebugLevel = 0x00FFFFFF works nicely, although
> > a lot of trace info is produced.
> 
> There is no AcpiDebugLevel in the Linux kernel.  I did find a
> variable "acpidbg_level" ... so I set CONFIG_ACPI_DEBUG=y and
> added
> 	acpi_dbg_level = 0x00FFFFFF;
> at the start of init/main.c/start_kernel()
> 
> But then my system didn't boot at all :-(
> 
> Tried again w/o the "acpi_dbg_level = 0x00FFFFFF;", and that didn't
> boot either.  So there is something bad in the CONFIG_ACPI_DEBUG
> code.
> 
> -Tony
