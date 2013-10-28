From: Bjorn Helgaas <bhelgaas@google.com>
Date: Mon, 28 Oct 2013 17:32:30 +0000
Subject: Re: [Resend PATCH 5/5] IA64/PCI/ACPI: Rework PCI root bridge ACPI resource conversion
Message-Id: <CAErSpo50_JQEhGOK6mcnaj36f6Fhgp3VcHKSmziC6JB_Ycu0Xg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1381493941-4650-1-git-send-email-tianyu.lan@intel.com>
 <1381493941-4650-6-git-send-email-tianyu.lan@intel.com> <20131016235541.GD17866@google.com>
 <525F7F0F.5010306@intel.com> <CAErSpo7P+n5c2uUoodT=LOjE3UH3LBcjifbj8reXzAeWydsoLA@mail.gmail.com>
 <52612D1C.4070701@intel.com> <20131023223904.GA18454@google.com> <526BF37E.8040801@intel.com>
In-Reply-To: <526BF37E.8040801@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Lan Tianyu <tianyu.lan@intel.com>
Cc: Tony Luck <tony.luck@intel.com>, Len Brown <lenb@kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "Yoknis, Mike" <mike.yoknis@hp.com>, "Pearson, Greg" <greg.pearson@hp.com>

On Sat, Oct 26, 2013 at 10:53 AM, Lan Tianyu <tianyu.lan@intel.com> wrote:
> On 10/24/2013 06:39 AM, Bjorn Helgaas wrote:
>> On Fri, Oct 18, 2013 at 08:44:12PM +0800, Lan Tianyu wrote:
>>>
>>> On 10/18/2013 04:33 AM, Bjorn Helgaas wrote:

>>>> I wonder if it would make sense to make
>>>> acpi_dev_resource_address_space() ignore addr.translation_offset for
>>>> IO resources.  Or maybe ignore it if the _TTP (type translation) bit
>>>> is set?
>>>
>>>
>>> I wonder why current code doesn't check _TTP? The code in the
>>> add_io_space() seems to think _TTP is always set, right?
>>
>> I think it's an oversight, and you should fix it.  I suggest that you
>> ignore the _TRA value when _TTP is set.  Obviously this only applies
>> to I/O port resources, since _TTP is only defined in the I/O Resource
>> Flag (Table 6-185 in ACPI 5.0 spec).
>
> _TTP is also defined in the Memory Resource flag, Please have a look at
> Table 6-184 in the ACPI 5.0 Spec.

Yes, you're right.  That would be for a host bridge that converts I/O
on the primary (upstream) side of the bridge to memory on the PCI
side.  I've never seen such a bridge, and I can't really imagine why
anybody would do that.  But I guess you should be able to safely
ignore _TRA when _TTP is set in either a MEM or IO descriptor, because
the same reasoning should apply to both.

> I am not sure how to deal with _TTP unsetting io resource? _TTP unsetting
> mean the resource is IO on the primary side and also IO on the secondary
> side.

If _TTP is not set, I guess you would apply _TRA.  That's what you
already do for MEM descriptors, and think you should just do the same
for IO descriptors.  I would guess that having _TTP = 0 and _TRA != 0
is rare for IO descriptors, but I suppose it could happen.

Bjorn
