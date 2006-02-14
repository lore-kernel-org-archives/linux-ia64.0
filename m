From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 14 Feb 2006 00:22:28 +0000
Subject: Re: some new unaligned access while booting ia64 (HP rx2620)
Message-Id: <200602131722.28703.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <971FCB6690CD0E4898387DBF7552B90E0452B0D7@orsmsx403.amr.corp.intel.com> <200602131533.53905.bjorn.helgaas@hp.com> <je7j7yc1f8.fsf@sykes.suse.de>
In-Reply-To: <je7j7yc1f8.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andreas Schwab <schwab@suse.de>
Cc: Thomas Renninger <trenn@suse.de>, "Moore, Robert" <robert.moore@intel.com>, "Luck, Tony" <tony.luck@intel.com>, "Brown, Len" <len.brown@intel.com>, linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org

On Monday 13 February 2006 15:57, Andreas Schwab wrote:
> Bjorn Helgaas <bjorn.helgaas@hp.com> writes:
> > I looked at both of those paths, and I don't see anything wrong.  I
> > tried unsuccessfully to reproduce it with an rc1-mm4 kernel on an
> > rx2600. 
> 
> Please try rx7620 or rx8640.  Apparently this only happens on the NUMA
> systems.

While I was reading your mail, I was booting an rx7620 for something else.
When I looked at it again, it was spewing the slab errors :-)

I don't have time to debug it completely today, but it looks like the
conversion of an AML vendor resource is overrunning the buffer.  p1
and p2 are pointers to the redzones before and after the object.
0x170fc2a5 is the correct value:

acpi_rs_create_resource_list: p1 0xe0000007fc1518f0 p2 0xe0000007fc1519f8
acpi_rs_create_resource_list: *p1 0x170fc2a5 *p2 0x170fc2a5
acpi_rs_convert_aml_to_resources: p1 0xe0000007fc1518f0 p2 0xe0000007fc1519f8
acpi_rs_convert_aml_to_resources: *p1 0x170fc2a5 *p2 0x170fc2a5
acpi_rs_convert_aml_to_resources: before converting AML resource 0x88: *p1 0x170fc2a5 *p2 0x170fc2a5
acpi_rs_convert_aml_to_resources: before converting AML resource 0x8a: *p1 0x170fc2a5 *p2 0x170fc2a5
acpi_rs_convert_aml_to_resources: before converting AML resource 0x8a: *p1 0x170fc2a5 *p2 0x170fc2a5
acpi_rs_convert_aml_to_resources: before converting AML resource 0x84: *p1 0x170fc2a5 *p2 0x170fc2a5
acpi_rs_convert_aml_to_resources: before converting AML resource 0x84: *p1 0x170fc2a5 *p2 0x170fc2a5
acpi_rs_convert_aml_to_resources: before converting AML resource 0x79: *p1 0x170fc2a5 *p2 0xf901001a00000028

AML resource type 0x84 is a vendor-defined descriptor.  This makes sense
because rx7620 and rx8620 have large vendor-defined descriptors, while
the smaller boxes like rx2600 do not.
