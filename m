From: "Li, Shaohua" <shaohua.li@intel.com>
Date: Tue, 26 Feb 2008 09:24:09 +0000
Subject: RE: Tiger oops in ia64_sal_physical_id_info (was [RFC] regression:113134fcbca83619be4c68d0ca66db6093
Message-Id: <FC1D1B23302A22499C60C967336B2AE0026C4080@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200802251027.15107.bjorn.helgaas@hp.com>
In-Reply-To: <200802251027.15107.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



>-----Original Message-----
>From: Alex Chiang [mailto:achiang@hp.com]
>Sent: Tuesday, February 26, 2008 3:15 PM
>To: Li, Shaohua
>Cc: Bjorn Helgaas; Luck, Tony; ia64
>Subject: Re: Tiger oops in ia64_sal_physical_id_info (was [RFC]
>regression:113134fcbca83619be4c68d0ca66db6093777b5d)
>
>* Shaohua Li <shaohua.li@intel.com>:
>>
>> On Mon, 2008-02-25 at 16:08 -0700, Alex Chiang wrote:
>> >
>> > My original commit relied on fall-through behavior to still
>> > try and call ia64_sal_physical_id_info(), because there are
>> > cases/platforms where PAL_LOGICAL_TO_PHYSICAL is not
>> > implemented but SAL_PHYSICAL_ID_INFO is.
>> >
>> > I think the more interesting question is, why is that SAL
>> > call hanging / oops'ing your machine rather than returning
>> > with an error code?
>> >
>> > In other words, why doesn't the error path work?
>>
>> Yes, this is strange. But other SAL calls are ok, maybe
>> firmware bug or something I don't know. I'm not familiar with
>> this area, if you need further info, let me know.
>
>Do you get anything useful (like the oops message) printed on the
>console or in your syslog?
>
>That might be a good first step.
SAL: AP wakeup using external interrupt vetor 0xf0
swapper[0]: IA-64 Illegal operation fault 0
Modules linked in:
Pid:0
CPU 0
comm: swapper
psr: 00001010084a2010 ifs:8000000000000818 ip:[<e00000017fe510f0>] Not
tained(2.6.24)
ip is at 0xe00000017fe510f0
unat:0000000000000 pfs0000000000038f rsc0000000000003
rnat 0000000000000 bsps 0000000000000, pr 656960155aa6809b
ldrs:000000000 ccv 00000000000 fpsr 0009804c8a70433f
...........


I can't get the log with serial console, so I copied by hand, so maybe
there are errors. There are a lot of other registers below, if you need
know, I'll copy them too
