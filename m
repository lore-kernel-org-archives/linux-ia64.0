From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Tue, 21 Nov 2017 12:52:45 +0000
Subject: Re: [PATCH] acpi, numa, ia64: Parse all entries of SRAT memory affinity table
Message-Id: <CAJZ5v0in=eK9RT5ODGYp8FEggCOKeRdxKdD3JkiAoxqTuveuWA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171115172902.20083-1-ganapatrao.kulkarni@cavium.com>
 <3908561D78D1C84285E8C5FCA982C28F779F2D18@ORSMSX110.amr.corp.intel.com> <CAKTKpr4xh8Taw82ikBHonjWSB-Ob_-LupC_QJiH=5GqnssAmfg@mail.gmail.com>
In-Reply-To: <CAKTKpr4xh8Taw82ikBHonjWSB-Ob_-LupC_QJiH=5GqnssAmfg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ganapatrao Kulkarni <gklkml16@gmail.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Ganapatrao Kulkarni <ganapatrao.kulkarni@cavium.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "Yu, Fenghua" <fenghua.yu@intel.com>, "rjw@rjwysocki.net" <rjw@rjwysocki.net>, "lenb@kernel.org" <lenb@kernel.org>, "guohanjun@huawei.com" <guohanjun@huawei.com>, "jnair@caviumnetworks.com" <jnair@caviumnetworks.com>, "gpkulkarni@gmail.com" <gpkulkarni@gmail.com>, "Robert.Richter@cavium.com" <Robert.Richter@cavium.com>

On Tue, Nov 21, 2017 at 5:16 AM, Ganapatrao Kulkarni <gklkml16@gmail.com> wrote:
> On Thu, Nov 16, 2017 at 12:16 AM, Luck, Tony <tony.luck@intel.com> wrote:
>>> This check is already added in x86 and extending same to ia64.
>>
>> Looks OK.
>>
>> Acked-by: Tony Luck <tony.luck@intel.com>
>
> thanks Tony.
>
> ACPI Maintainers,
> any comments on this patch? i can send rebasing to 4.15-rc1?

I've queued it up already.

Is there any urgent need for that to go into 4.15?

Thanks,
Rafael
