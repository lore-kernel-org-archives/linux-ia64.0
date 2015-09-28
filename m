From: Mathias Krause <minipli@googlemail.com>
Date: Mon, 28 Sep 2015 05:28:52 +0000
Subject: Re: [PATCH 0/3] ia64: Remove unneeded __ref / __refdata annotations
Message-Id: <CA+rthh9vzHKu8owFt-+fZ=5+EAXD3MwZSw35U2A7YzQw05MunQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 18 August 2015 at 08:04, Mathias Krause <minipli@googlemail.com> wrote:
> On 19 July 2015 at 17:05, Mathias Krause <minipli@googlemail.com> wrote:
>> This series removes unneeded __ref / __refdata annotations that have
>> become mostly obsolete since the __cpuinit removal in v3.11.
>>
>> Please apply.
>>
>> Mathias Krause (3):
>>   ACPI / ia64: Get rid of the acpi_map_cpu() wrapper
>>   ia64, topology: Remove bogus __ref annotations
>>   ia64, palinfo: Remove bogus __refdata annotation
>>
>>  arch/ia64/kernel/acpi.c     |    8 +-------
>>  arch/ia64/kernel/palinfo.c  |    2 +-
>>  arch/ia64/kernel/topology.c |    4 ++--
>>  3 files changed, 4 insertions(+), 10 deletions(-)
>>
>
> Ping. Tony, Fenghua, any objections to this series?

Ping. Should those patches better go though the ACPI tree?

Mathias
