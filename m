From: David Daney <ddaney@caviumnetworks.com>
Date: Tue, 26 Apr 2016 16:48:28 +0000
Subject: Re: [PATCH v5 00/14] ACPI NUMA support for ARM64
Message-Id: <571F9BDC.5090804@caviumnetworks.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1461116439-22991-1-git-send-email-ddaney.cavm@gmail.com> <20160425111338.GJ16065@arm.com> <571E4A2A.8070908@caviumnetworks.com> <571EFD1B.1070609@linaro.org> <20160426121547.GL27312@arm.com> <571F671D.70401@linaro.org> <20160426133500.GQ27312@arm.com>
In-Reply-To: <20160426133500.GQ27312@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Will Deacon <will.deacon@arm.com>
Cc: Hanjun Guo <hanjun.guo@linaro.org>, David Daney <ddaney@caviumnetworks.com>, linux-arm-kernel@lists.infradead.org, Mark Rutland <mark.rutland@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Grant Likely <grant.likely@linaro.org>, Robert Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, Marc Zyngier <Marc.Zyngier@arm.com>, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, linux-kernel@vger.kernel.org, Robert Richter <rrichter@cavium.com>, David Daney <david.daney@cavium.com>

On 04/26/2016 06:35 AM, Will Deacon wrote:
> On Tue, Apr 26, 2016 at 09:03:25PM +0800, Hanjun Guo wrote:
>> On 2016/4/26 20:15, Will Deacon wrote:
>>> On Tue, Apr 26, 2016 at 01:31:07PM +0800, Hanjun Guo wrote:
>>>> On 2016/4/26 0:47, David Daney wrote:
[...]
>>>>>> Given that this ACPI series already requires some significant cross-arch
>>>>>> interaction (which is actually good!), perhaps extending the clean-up
>>>>>> patches to encompass some of the ACPI bits might make sense, and we can
>>>>>> get that queued as a pre-requisite.
>>>>>
>>>>> The cleanup patches you mention above are really independent of the ACPI
>>>>> things.  I have applied them both before and after the ACPI patches, and
>>>>> both seem to work.  With a quick perusal of the ACPI patches nothing
>>>>> jumps out at me as being a candidate for inclusion in the header file
>>>>> cleanup series.
>>>>
>>>> I agree. My patch set is ACPI related enablement, cleanups and
>>>> consolidations, it would be good to merge as a single patch set
>>>> as it's self-contained.
>>>
>>> Up to you. I just thought you might want to avoid having two sets of
>>> cross-arch changes and the associated merging headaches that go with
>>> that.
>>
>> Good point, as I suggested above, it can go with ACPI tree if it's ok
>> to you and Rafael. The problem we have now is that dt based core NUMA
>> support for ARM64 is queued in your tree, that would be the headache.
>
> Sorry, but if you wanted me *not* to queue the patches, then you should
> have said so (similarly, if you wanted a stable branch). I'm not rebasing
> our for-next/core branch now.

I am quite happy with the fact that you put the base device-tree based 
NUMA patches on for-next/core.

There is only a very small adjustment to those in the ACPI-NUMA patches 
([PATCH v5 06/14] arm64, numa: rework numa_add_memblk()), so I think we 
are fine as far as that goes.

My plan is to post a v6 later today that adjusts some of the messages 
printed out and adds some Reviewed-by and Acked-by that were accumulated.

David.


