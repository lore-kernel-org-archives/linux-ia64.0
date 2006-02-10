From: "Moore, Robert" <robert.moore@intel.com>
Date: Fri, 10 Feb 2006 23:31:03 +0000
Subject: RE: some new unaligned access while booting ia64 (HP rx2620)
Message-Id: <971FCB6690CD0E4898387DBF7552B90E0452B0D7@orsmsx403.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200602021946.k12Jk446028921@agluck-lia64.sc.intel.com>
In-Reply-To: <200602021946.k12Jk446028921@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>, Thomas Renninger <trenn@suse.de>, "Brown, Len" <len.brown@intel.com>
Cc: linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org

This only contains the output of stores to the ACPI "debug" object, not
the full trace output. However, "_CRS 0" may help


i.e., like this:

> exstoren-0075 [18] ex_resolve_object     : ----Entry
> exstoren-0155 [18] ex_resolve_object     : ----Exit- AE_OK


> -----Original Message-----
> From: Luck, Tony
> Sent: Friday, February 10, 2006 3:25 PM
> To: Moore, Robert; 'Thomas Renninger'; Brown, Len
> Cc: 'linux-acpi@vger.kernel.org'; 'linux-ia64@vger.kernel.org'
> Subject: RE: some new unaligned access while booting ia64 (HP rx2620)
> 
> A 16MB log_buf was enough.
> 
> Here is the initial trace up until the unaligned access messages:
> 
> Linux version 2.6.16-rc2-zx1-smp (aegl@linux-t10) (gcc version 3.4.3
> [ACPI Debug]  Integer: 0x00000000
> [ACPI Debug]  String: [0x1F] "PARS.GUID: evaluating for COMP2"
> [ACPI Debug]  Integer: 0x00000001
> [ACPI Debug]  String: [0x12] "SERIAL DEV Ptr is "
> [ACPI Debug]  Integer: 0x3FEF99A0
> kernel unaligned access to 0xe000004040e7a434, ip=0xa0000001003c81a0
> kernel unaligned access to 0xe000004040e7a46c, ip=0xa0000001003c81a0
> kernel unaligned access to 0xe000004040e7a4bc, ip=0xa0000001003c81a0
> kernel unaligned access to 0xe000004040e7a42c, ip=0xa0000001003c6ca1
> kernel unaligned access to 0xe000004040e7a434, ip=0xa0000001003c6cb1
> [ACPI Debug]  String: [0x06] "_CRS 0"
> [ACPI Debug]  String: [0x0A] "CLIB.LBA 1"
> [ACPI Debug]  Integer: 0x00000000
> [ACPI Debug]  String: [0x0B] "PARS.GPTR 2"
