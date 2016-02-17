From: Sudeep Holla <sudeep.holla@arm.com>
Date: Wed, 17 Feb 2016 11:37:51 +0000
Subject: Re: [PATCH v3 0/5] ACPI / processor_idle: Add ACPI v6.0 LPI support
Message-Id: <56C45B8F.4000509@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1449065446-26115-1-git-send-email-sudeep.holla@arm.com>
 <4399656.WBgE1pMnz5@vostro.rjw.lan>
In-Reply-To: <4399656.WBgE1pMnz5@vostro.rjw.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Sudeep Holla <sudeep.holla@arm.com>, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, x86@kernel.org, Al Stone <al.stone@linaro.org>, Lorenzo Pieralisi <Lorenzo.Pieralisi@arm.com>, Mahesh Sivasubramanian <msivasub@codeaurora.org>, Ashwin Chaugule <ashwin.chaugule@linaro.org>, Prashanth Prakash <pprakash@codeaurora.org>



On 16/02/16 20:08, Rafael J. Wysocki wrote:
> On Wednesday, December 02, 2015 02:10:41 PM Sudeep Holla wrote:
>> ACPI 6.0 introduced LPI(Low Power Idle) states that provides an alternate
>> method to describe processor idle states. It extends the specification
>> to allow the expression of idle states like C-states selectable by the
>> OSPM when a processor goes idle, but may affect more than one processor,
>> and may affect other system components.
>>
>> LPI extensions leverages the processor container device(again introduced
>> in ACPI 6.0) allowing to express which parts of the system are affected
>> by a given LPI state. It defines the local power states for each node
>> in a hierarchical processor topology. The OSPM can use _LPI object to
>> select a local power state for each level of processor hierarchy in the
>> system. They used to produce a composite power state request that is
>> presented to the platform by the OSPM.
>>
>> Since multiple processors affect the idle state for any non-leaf hierarchy
>> node, coordination of idle state requests between the processors is
>> required. ACPI supports two different coordination schemes: Platform
>> coordinated and  OS initiated.
>>
>> This series aims at providing basic and initial support for platform
>> coordinated LPI states.
>>
>> v2[2]->v3:
>> 	- rebased against v4.4-rc3
>> 	- fixed couple of issues reported by Prashanth and review comments
>> 	  from Ashwin
>>
>> v1[1]->v2[2]:
>> 	- Fixed support for ACPI0010 processor container
>> 	- moved sleep state code out of processor_idle
>>
>> Note the ARM64 specific changes are not part of this series as it's still
>> WIP and there are other consolidation happening in there. For reference
>> and testing, I have pushed a branch[3]
>
> Sorry for the slow response here.
>

No problem, I saw you were quite busy with cpufreq timers past couple of
weeks so didn't bother you.

> It doesn't look too bad overall, but there are some things in it I'd like to
> be done differenty.  Please see comments on the individual patches.
>

OK, thanks for the review, will look at them.

-- 
Regards,
Sudeep
