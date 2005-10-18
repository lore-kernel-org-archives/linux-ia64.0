From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 18 Oct 2005 17:06:29 +0000
Subject: RE: [PATCH] set altix preferred console
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F04B1E7CA@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050930200422.GD13855@sgi.com>
In-Reply-To: <20050930200422.GD13855@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> > I don't want to move pcdp.h under asm-ia64.  EFI (and, I hope,
>> > PCDP) is coming to x86 soon.  There's nothing ia64-specific
>> > in pcdp.h or pcdp.c, so I think it would be a mistake to
>> > move it to an arch-specific directory.
>> 
>> Ok, thanks Bjorn.  I was under the impression that stuff under dig64.org
>> was ia64 specific ...
>> 
>> Would moving it to include/linux be an option?
>
>I sort of hate to put it in include/linux, too, but I guess
>it's already a dumping ground for all sorts of miscellaneous
>stuff, so one more wouldn't make it much worse.
>
>And I can't think of any better options.

The comments at the head of pcdp.h certainly make it look
very ia64 specific.  Are there any newer EFI documents that
it could point to instead of the dig64.org URLs?

Linus is just as fond of EFI as he is of ACPI (i.e. not at all),
so I don't think he'll be too happy with include/linux/pcdp.h
If it really is the only place for this to move, then this discussion
needs to happen on linux-kernel, not on linux-ia64.

Since PCDP is closely linked to ACPI, would include/acpi/pcdp.h
be at all plausible?  At least this keeps all the bits Linus
doesn't like together and he can more easily avert his eyes.

Or, merge the contents into include/linux/efi.h?

-Tony



