From: "Moore, Robert" <robert.moore@intel.com>
Date: Fri, 10 Feb 2006 20:11:51 +0000
Subject: RE: some new unaligned access while booting ia64 (HP rx2620)
Message-Id: <971FCB6690CD0E4898387DBF7552B90E0452ACB2@orsmsx403.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200602021946.k12Jk446028921@agluck-lia64.sc.intel.com>
In-Reply-To: <200602021946.k12Jk446028921@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Renninger <trenn@suse.de>
Cc: "Luck, Tony" <tony.luck@intel.com>, linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org

When the resource descriptor list (ResourceTemplate) is extracted from
the raw AML byte stream, it is converted and expanded to an internal
format that is easier for the drivers to interpret. For IA64, this
includes alignment of the various structs on 64-bit boundaries.

I suspect that the recent restructuring of the Resource Manager code may
have broken some of the alignment support. Obviously, we don't see any
issues on the 32-bit machines. 

What I need is to know exactly what control method has executed and what
resource descriptor is being processed when the alignment fault(s)
occur. 

Enabling debugging in the ACPI subsystem will certainly give this
information. AcpiDebugLevel = 0x00FFFFFF works nicely, although a lot of
trace info is produced. You can tweak the number above to get just the
info you need, or enable/disable debugging around a particular piece of
code, such as in a driver that is calling the ACPI subsystem to get the
resource descriptor template.

Also, the length of the target buffer for the resource descriptors is
calculated taking alignment issues into account. If this is out of sync
with the code that actually populates the buffer, the buffer can be
overrun.

Bob


> -----Original Message-----
> From: Thomas Renninger [mailto:trenn@suse.de]
> Sent: Thursday, February 09, 2006 6:08 PM
> To: Moore, Robert
> Cc: Luck, Tony; linux-acpi@vger.kernel.org; linux-ia64@vger.kernel.org
> Subject: Re: some new unaligned access while booting ia64 (HP rx2620)
> 
> Moore, Robert wrote:
> > The next thing that would be useful is to know what method(s) are
> > executing when the message pops out.
> >
> >
> >> -----Original Message-----
> >> From: Luck, Tony
> >> Sent: Thursday, February 09, 2006 1:16 PM
> >> To: Moore, Robert; 'linux-acpi@vger.kernel.org'
> >> Cc: 'linux-ia64@vger.kernel.org'
> >> Subject: RE: some new unaligned access while booting ia64 (HP
rx2620)
> >>
> >> But I goofed and muddled up my two problems.  I tried
> >> booting on my zx1 ... which was broken altogether by
> >> recent acpi changes.
> >>
> >> Getting back to the rx2620 ... deleting those lines makes
> >> no difference.  I still boot ok, I still see the unaligned
> >> access messages.
> >>
> >> /proc/acpi/dsdt for that system attached.
> >>
> >> -Tony
> 
> I also got kernel missalignment errors..., unfortunately also
> a lot of slab debugger errors until the machine rebooted, so
> I didn't care too much about the missalignments, but these
> could have the same cause?
> 
> I now could nail the mem
> corruptions down to ACPICA-20051021 by binary search.
> It's late, maybe I got something wrong, but I am quite sure the
> culprit lies there.
> 
> The patch is huge, but maybe it's just one of the other pragmas or
> whatever related?:
> 
> grep pragma ../ACPICA_20051021.patch
> +#pragma pack(1)
> +#pragma pack()
> +#pragma pack(1)
> +#pragma pack()
> 
> 
>      Thomas
