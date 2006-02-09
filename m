From: "Moore, Robert" <robert.moore@intel.com>
Date: Thu, 09 Feb 2006 20:55:01 +0000
Subject: RE: some new unaligned access while booting ia64 (HP rx2620)
Message-Id: <971FCB6690CD0E4898387DBF7552B90E044F0525@orsmsx403.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200602021946.k12Jk446028921@agluck-lia64.sc.intel.com>
In-Reply-To: <200602021946.k12Jk446028921@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>, linux-acpi@vger.kernel.org
Cc: linux-ia64@vger.kernel.org

Well, we need to know which it was.

The alignment stuff is based upon __IA64__ or __ia64__, make sure one of
these is set.


/*
 * In the case of the Itanium Processor Family (IPF), the hardware does
not
 * support misaligned memory transfers. Set the
MISALIGNMENT_NOT_SUPPORTED flag
 * to indicate that special precautions must be taken to avoid alignment
faults.
 * (IA64 or ia64 is currently used by existing compilers to indicate
IPF.)
 *
 * Note: EM64T and other X86-64 processors support misaligned transfers,
 * so there is no need to define this flag.
 */
#if defined (__IA64__) || defined (__ia64__)
#define ACPI_MISALIGNMENT_NOT_SUPPORTED
#endif


> -----Original Message-----
> From: Luck, Tony
> Sent: Thursday, February 09, 2006 12:45 PM
> To: Moore, Robert; 'linux-acpi@vger.kernel.org'
> Cc: 'linux-ia64@vger.kernel.org'
> Subject: RE: some new unaligned access while booting ia64 (HP rx2620)
> 
> > You might try removing this code from actypes.h:
> >
> > /*
> >  * If possible, pack the following structures to byte alignment
> >  */
> > #ifndef ACPI_MISALIGNMENT_NOT_SUPPORTED
> > #pragma pack(1)
> > #endif
> 
> Either this made things worse, or other changes in the base since
> my last test made things worse ... after rebuilding with those lines
> deleted my kernel got less far.  Last messages were:
> 
>    Initial ramdisk at: 0xe00000003e43b000 (1303588 bytes)
>    SAL 3.1: HP version 2.21
>    SAL Platform features: None
> 
> > Please send the dsdt or acpidump for this machine
> 
> /proc/acpi/dsdt attached.
> 
> -Tony
