From: "Yu, Luming" <luming.yu@intel.com>
Date: Wed, 10 Mar 2004 11:13:00 +0000
Subject: RE: cat /proc/acpi/events bad for your system's health!
Message-Id: <3ACA40606221794F80A5670F0AF15F8401CBB73E@PDSMSX403.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16455.50905.681007.50048@napali.hpl.hp.com>
In-Reply-To: <16455.50905.681007.50048@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I confirm this issue here on tiger with 2.6.4-rc3 kernel , but 2.4 is
ok.
Not sure this is a regression. 

PS . please forget my previous reply against this thread. :(

Thanks,
Luming

> -----Original Message-----
> From: David Mosberger [mailto:davidm@napali.hpl.hp.com] 
> Sent: Tuesday, March 09, 2004 3:10 AM
> To: Yu, Luming
> Cc: davidm@hpl.hp.com; Brown, Len; linux-ia64@vger.kernel.org
> Subject: RE: cat /proc/acpi/events bad for your system's health!
> 
> 
> >>>>> On Mon, 8 Mar 2004 13:21:34 +0800, "Yu, Luming" 
> <luming.yu@intel.com> said:
> 
>   Luming> Regarding unalignment access issue, Bob have the following
>   Luming> patch integrated into 20040220.  Would it help this cases?
> 
> The primary problem is not the unaligned access, it's an access to
> a bogus address:
> 
>   >> kernel unaligned access to 0xffffffffffffffff,
> 
> Are you saying that /proc/acpi/events works for you as expected with
> the updated ACPI?
> 
> 	--david
> 
