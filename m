From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Date: Thu, 17 Sep 2015 00:34:26 +0000
Subject: Re: [PATCH v3 0/5] ACPI: Provide better MADT subtable sanity checks
Message-Id: <2360913.mWVNIccye0@vostro.rjw.lan>
List-Id: <linux-ia64.vger.kernel.org>
References: <1441832991-28200-1-git-send-email-al.stone@linaro.org> <55F997C1.20606@linaro.org> <55F9988D.5080002@redhat.com>
In-Reply-To: <55F9988D.5080002@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Al Stone <ahs3@redhat.com>
Cc: Al Stone <al.stone@linaro.org>, linux-acpi@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-pm@vger.kernel.org, linaro-acpi@lists.linaro.org, linaro-kernel@lists.linaro.org, patches@linaro.org, "lenb@kernel.org" <lenb@kernel.org>, "tony.luck@intel.com" <tony.luck@intel.com>, "fenghua.yu@intel.com" <fenghua.yu@intel.com>, Pavel Machek <pavel@ucw.cz>, "tglx@linutronix.de" <tglx@linutronix.de>, mingo@redhat.com, "H. Peter Anvin" <hpa@linux.intel.com>

On Wednesday, September 16, 2015 10:27:57 AM Al Stone wrote:
> On 09/16/2015 10:24 AM, Al Stone wrote:
> > On 09/15/2015 08:44 PM, Rafael J. Wysocki wrote:
> >> On Tuesday, September 15, 2015 03:13:12 PM Al Stone wrote:
> >>> On 09/09/2015 03:09 PM, Al Stone wrote:
> >>>> Currently, the BAD_MADT_ENTRY macro is used to do a very simple sanity
> >>>> check on the various subtables that are defined for the MADT.  The check
> >>>> compares the size of the subtable data structure as defined by ACPICA to
> >>>> the length entry in the subtable.  If they are not the same, the assumption
> >>>> is that the subtable is incorrect.
> >>>>
> 
> [snip...]
> 
> >> I'm going to apply this series if people have no problems with it.  I do think
> >> it is slightly overkill, but then as long as it works ...
> >>
> >> Thanks,
> >> Rafael
> >>
> 
> Would you prefer I send out the updated version with Sudeep's fix to apply
> instead of this version?

Yes, I would.

> Or have you picked that up already?

No, I haven't.

> Easily updated and sent out, if it'll make your life simpler....

Yes, please.

Thanks,
Rafael

