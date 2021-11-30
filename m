From: Kefeng Wang <wangkefeng.wang@huawei.com>
Date: Tue, 30 Nov 2021 06:22:07 +0000
Subject: Re: [PATCH RFC 1/4] mm: percpu: Generalize percpu related config
Message-Id: <35e4a4cb-29f2-2de6-6350-1358d4968a54@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211121093557.139034-1-wangkefeng.wang@huawei.com>
 <20211121093557.139034-2-wangkefeng.wang@huawei.com>
 <YaVV38QSn6LEBKH/@fedora>
In-Reply-To: <YaVV38QSn6LEBKH/@fedora>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dennis Zhou <dennis@kernel.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tj@kernel.org, gregkh@linuxfoundation.org, cl@linux.com, catalin.marinas@arm.com, will@kernel.org, tsbogend@alpha.franken.de, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, paul.walmsley@sifive.com, palmer@dabbelt.com, aou@eecs.berkeley.edu, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, hpa@zytor.com, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, sparclinux@vger.kernel.org, x86@kernel.org


On 2021/11/30 6:36, Dennis Zhou wrote:
> Hello,
>
> On Sun, Nov 21, 2021 at 05:35:54PM +0800, Kefeng Wang wrote:
>> The HAVE_SETUP_PER_CPU_AREA/NEED_PER_CPU_EMBED_FIRST_CHUNK/
>> NEED_PER_CPU_PAGE_FIRST_CHUNK/USE_PERCPU_NUMA_NODE_ID configs,
>> which has duplicate definitions on platforms that subscribe it.
>>
>> Move them into mm, drop these redundant definitions and instead
>> just select it on applicable platforms.
>>
>> Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>
>> ---
>>   arch/arm64/Kconfig   | 20 ++++----------------
>>   arch/ia64/Kconfig    |  9 ++-------
>>   arch/mips/Kconfig    | 10 ++--------
>>   arch/powerpc/Kconfig | 17 ++++-------------
>>   arch/riscv/Kconfig   | 10 ++--------
>>   arch/sparc/Kconfig   | 12 +++---------
>>   arch/x86/Kconfig     | 17 ++++-------------
>>   mm/Kconfig           | 12 ++++++++++++
>>   8 files changed, 33 insertions(+), 74 deletions(-)
...
>>
> This makes sense and looks good. A series like this is a little tricky.
> The latter patches change the contracts so it'd be easiest to run it
> through my tree. We'd need to get explicit acks from each arch
> maintainer to make sure they're fine with this.

Got it, I will resend without RFC and hope to get ACKs from related arch 
maintainers.


>
> Thanks,
> Dennis
> .
