From: Lan Tianyu <tianyu.lan@intel.com>
Date: Fri, 06 Sep 2013 16:35:03 +0000
Subject: Re: [RFC PATCH 4/4] X86/PCI/ACPI: Rework setup_resource() via functions ACPI resource functions
Message-Id: <522A0437.40802@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1378477486-8758-1-git-send-email-tianyu.lan@intel.com> <1378477486-8758-5-git-send-email-tianyu.lan@intel.com> <CAErSpo5rWq0+CbPMtjruDv0eN8-q=qBhHQURFeia_CfOgmDotA@mail.gmail.com> <5229FC3D.9040308@intel.com> <CAErSpo4=Bs4r+JMYjps=XvtOLeGmckJYJ508yMT1nRR=_KLz0g@mail.gmail.com>
In-Reply-To: <CAErSpo4=Bs4r+JMYjps=XvtOLeGmckJYJ508yMT1nRR=_KLz0g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Len Brown <lenb@kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

On 09/06/2013 12:10 PM, Bjorn Helgaas wrote:
> On Fri, Sep 6, 2013 at 10:01 AM, Lan Tianyu <tianyu.lan@intel.com> wrote:
>> On 09/06/2013 11:36 AM, Bjorn Helgaas wrote:
>
>>> Please make corresponding changes to arch/ia64/pci/pci.c so that these
>>> paths remain as similar as possible.  There's quite a bit of
>>> similarity between this x86 and ia64 code, and it would be nice to
>>> unify them more when possible.
>>>
>>
>> OK. Actually, I have such plan. I will do that if there is no objection on
>> this patchset.
>
> Great, I'm glad to hear that!  I'm not sure whether you mean "after
> this patchset is accepted" or "as part of this patchset if it seems a
> reasonable path."  I vote for the latter, because if we put in the
> parts people care about, i.e., x86, the rest seems to never happen.
> That's not surprising; whose manager will approve extra time to work
> on an arch that's not on their critical path?  But in my opinion,
> doing just x86 is only doing half the job, and we have to do the whole
> thing if we want to keep Linux maintainable in the future.

I mean the later. :).
Yes, Linux maintainable is very important.
My plan is to find all such cases of converting ACPI resource to generic 
resource but not using ACPI resource function and rework them.


>
> Bjorn
>

