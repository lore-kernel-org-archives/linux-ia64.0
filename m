From: Bjorn Helgaas <bhelgaas@google.com>
Date: Fri, 06 Sep 2013 16:10:14 +0000
Subject: Re: [RFC PATCH 4/4] X86/PCI/ACPI: Rework setup_resource() via functions ACPI resource functions
Message-Id: <CAErSpo4=Bs4r+JMYjps=XvtOLeGmckJYJ508yMT1nRR=_KLz0g@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1378477486-8758-1-git-send-email-tianyu.lan@intel.com>
 <1378477486-8758-5-git-send-email-tianyu.lan@intel.com> <CAErSpo5rWq0+CbPMtjruDv0eN8-q=qBhHQURFeia_CfOgmDotA@mail.gmail.com>
 <5229FC3D.9040308@intel.com>
In-Reply-To: <5229FC3D.9040308@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Lan Tianyu <tianyu.lan@intel.com>
Cc: Len Brown <lenb@kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

On Fri, Sep 6, 2013 at 10:01 AM, Lan Tianyu <tianyu.lan@intel.com> wrote:
> On 09/06/2013 11:36 AM, Bjorn Helgaas wrote:

>> Please make corresponding changes to arch/ia64/pci/pci.c so that these
>> paths remain as similar as possible.  There's quite a bit of
>> similarity between this x86 and ia64 code, and it would be nice to
>> unify them more when possible.
>>
>
> OK. Actually, I have such plan. I will do that if there is no objection on
> this patchset.

Great, I'm glad to hear that!  I'm not sure whether you mean "after
this patchset is accepted" or "as part of this patchset if it seems a
reasonable path."  I vote for the latter, because if we put in the
parts people care about, i.e., x86, the rest seems to never happen.
That's not surprising; whose manager will approve extra time to work
on an arch that's not on their critical path?  But in my opinion,
doing just x86 is only doing half the job, and we have to do the whole
thing if we want to keep Linux maintainable in the future.

Bjorn
