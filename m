From: Lan Tianyu <tianyu.lan@intel.com>
Date: Wed, 30 Oct 2013 08:34:04 +0000
Subject: Re: [Resend PATCH 5/5] IA64/PCI/ACPI: Rework PCI root bridge ACPI resource conversion
Message-Id: <5270C47C.5040206@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1381493941-4650-1-git-send-email-tianyu.lan@intel.com> <1381493941-4650-6-git-send-email-tianyu.lan@intel.com> <20131016235541.GD17866@google.com> <525F7F0F.5010306@intel.com> <CAErSpo7P+n5c2uUoodT=LOjE3UH3LBcjifbj8reXzAeWydsoLA@mail.gmail.com> <52612D1C.4070701@intel.com> <20131023223904.GA18454@google.com> <526BF37E.8040801@intel.com> <CAErSpo50_JQEhGOK6mcnaj36f6Fhgp3VcHKSmziC6JB_Ycu0Xg@mail.gmail.com>
In-Reply-To: <CAErSpo50_JQEhGOK6mcnaj36f6Fhgp3VcHKSmziC6JB_Ycu0Xg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Tony Luck <tony.luck@intel.com>, Len Brown <lenb@kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "Yoknis, Mike" <mike.yoknis@hp.com>, "Pearson, Greg" <greg.pearson@hp.com>

On 2013年10月29日 01:32, Bjorn Helgaas wrote:
> On Sat, Oct 26, 2013 at 10:53 AM, Lan Tianyu <tianyu.lan@intel.com> wrote:
>> On 10/24/2013 06:39 AM, Bjorn Helgaas wrote:
>>> On Fri, Oct 18, 2013 at 08:44:12PM +0800, Lan Tianyu wrote:
>>>>
>>>> On 10/18/2013 04:33 AM, Bjorn Helgaas wrote:
>
>>>>> I wonder if it would make sense to make
>>>>> acpi_dev_resource_address_space() ignore addr.translation_offset for
>>>>> IO resources.  Or maybe ignore it if the _TTP (type translation) bit
>>>>> is set?
>>>>
>>>>
>>>> I wonder why current code doesn't check _TTP? The code in the
>>>> add_io_space() seems to think _TTP is always set, right?
>>>
>>> I think it's an oversight, and you should fix it.  I suggest that you
>>> ignore the _TRA value when _TTP is set.  Obviously this only applies
>>> to I/O port resources, since _TTP is only defined in the I/O Resource
>>> Flag (Table 6-185 in ACPI 5.0 spec).
>>
>> _TTP is also defined in the Memory Resource flag, Please have a look at
>> Table 6-184 in the ACPI 5.0 Spec.
>
> Yes, you're right.  That would be for a host bridge that converts I/O
> on the primary (upstream) side of the bridge to memory on the PCI
> side.  I've never seen such a bridge, and I can't really imagine why
> anybody would do that.  But I guess you should be able to safely
> ignore _TRA when _TTP is set in either a MEM or IO descriptor, because
> the same reasoning should apply to both.
>
>> I am not sure how to deal with _TTP unsetting io resource? _TTP unsetting
>> mean the resource is IO on the primary side and also IO on the secondary
>> side.
>
> If _TTP is not set, I guess you would apply _TRA.  That's what you
> already do for MEM descriptors, and think you should just do the same
> for IO descriptors.  I would guess that having _TTP = 0 and _TRA != 0
> is rare for IO descriptors, but I suppose it could happen.

Yes, my concern is for the IO resource case of _TTP=0 and _TRA !=0. The
only reason for this case I think of is that the IO resource offsets on
the prime bus and second bus are different. In this case, we still need
to pass _TRA to new_space() and the finial resource->start still should 
be acpi_resource->min + offset returned by add_io_space(), right?

If yes, I think _TRA can't be applied to IO resource in the
acpi_dev_resource_address_space() regardless of the value of _TTP.

BTW, Translation Sparse(_TRS) is only meaningful if _TTP is set.(Table 
6-185). The add_io_space() doesn't check _TTP when set sparse. So this 
should be corrected?

>
> Bjorn
>


-- 
Best regards
Tianyu Lan
