From: David Daney <ddaney@caviumnetworks.com>
Date: Wed, 27 Apr 2016 15:40:08 +0000
Subject: Re: [PATCH v5 12/14] arm64, acpi, numa: NUMA support based on SRAT and SLIT
Message-Id: <5720DD58.3020506@caviumnetworks.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1461116439-22991-1-git-send-email-ddaney.cavm@gmail.com> <1461116439-22991-13-git-send-email-ddaney.cavm@gmail.com> <CADKHWadFBh2TbyoZSmYJHX24roMQQXf8Kx8rEoLABJ8xaTGL=Q@mail.gmail.com> <5720127E.1030307@caviumnetworks.com> <57203A47.9000108@linaro.org> <CADKHWadTL5dB__Y-LGtoPs_mQQ+A36nnhwJo3muTC_z9X1FZag@mail.gmail.com>
In-Reply-To: <CADKHWadTL5dB__Y-LGtoPs_mQQ+A36nnhwJo3muTC_z9X1FZag@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dennis Chen <dennis.chen@linaro.org>
Cc: Hanjun Guo <hanjun.guo@linaro.org>, David Daney <ddaney.cavm@gmail.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Mark Rutland <mark.rutland@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Grant Likely <grant.likely@linaro.org>, Robert Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, Marc Zyngier <Marc.Zyngier@arm.com>, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, linux-kernel@vger.kernel.org, Robert Richter <rrichter@cavium.com>, Ganapatrao

On 04/27/2016 04:37 AM, Dennis Chen wrote:
> Hi Hanjun,
>
> Thanks for the clarification and some little comments ;-)
>
> On 27 April 2016 at 12:04, Hanjun Guo <hanjun.guo@linaro.org> wrote:
>> Hi Dennis, David,
>>
[...]
>>
>>
>> Yes, we can get such information in /sys/devices/system/node, I think
>> we can only print:
>>
>> ACPI: NUMA: SRAT: PXM x -> MPIDR y -> Node z
> Agree.

I am also in agreement.  I will send a revised patch that implements this.

Thanks,
David.

