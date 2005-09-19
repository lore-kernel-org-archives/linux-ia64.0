From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 19 Sep 2005 15:31:20 +0000
Subject: Re: [ACPI] [PATCH] ACPI: implement UUID-labelled vendor-defined resources
Message-Id: <200509190931.20643.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <971FCB6690CD0E4898387DBF7552B90E02C0B5F2@orsmsx403.amr.corp.intel.com>
In-Reply-To: <971FCB6690CD0E4898387DBF7552B90E02C0B5F2@orsmsx403.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: acpi-devel@lists.sourceforge.net
Cc: "Moore, Robert" <robert.moore@intel.com>, "Brown, Len" <len.brown@intel.com>, Alex Williamson <alex.williamson@hp.com>, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org

On Friday 16 September 2005 3:56 pm, Moore, Robert wrote:
> And to make things even more interesting, the base ACPICA code looks
> nothing like the final Linux version of the code; it is converted on the
> fly before every release to Linux.

Well, if you decide you'll integrate the code, I can dig out the
pre-converted ACPICA code and make a patch against it.

> BTW, Please explain in more detail what support is needed in ACPICA for
> the ACPI 3.0 vendor-defined resource.  Also, any idea how we are
> supposed to determine if the UUID data exists within the descriptor?
> (i.e., how do we differentiate an ACPI 2.0 vendor descriptor from an
> ACPI 3.0 descriptor?)

There's no mark that distinguishes 2.0 and 3.0 vendor descriptors.
As far as I can tell, a 3.0 descriptor (that contains a UUID and
sub-type) is also a perfectly valid 2.0 descriptor.

ACPI 3.0 "strongs recommends," but apparently doesn't actually
require a UUID, so a 2.0 vendor descriptor should also be a valid
3.0 descriptor.

The idea is that we just look through all the vendor descriptors
for the supplied UUID.  If we find one, we return the information.
There's a small possibility that an ACPI 2.0, non-UUID-labelled
descriptor will contain data that happens to match the random
16-byte UUID, and we'll return it by mistake.  But that possibility
is pretty remote, I think.

The point of having this code in ACPICA is so that people who
use UUID-labelled vendor descriptors can do something simple
like this:

> struct acpi_vendor_descriptor hp_ccsr_descriptor = {
>         .uuid_subtype = 2,
>         .uuid = ACPI_UUID(0x69e9adf9, 0x924f, 0xab5f, 0xf6, 0x4a, 0x24, 0xd2,
>                           0x01, 0x37, 0x0e, 0xad)
> };
> 
> acpi_status hp_acpi_csr_space(acpi_handle obj, u64 * csr_base, u64 * csr_length)
> {
>...
>         status = acpi_find_vendor_resource(obj, &hp_ccsr_descriptor, &data,
>                 &length);

rather than having to duplicate the implementation of
acpi_find_vendor_resource().  But that's an obvious answer.
Maybe you had a deeper question that I missed?

This is pretty generic stuff, certainly not ia64-, or even OS-
dependent.  So I thought ACPICA would be a logical place for it.
If you have other suggestions, let me know.
