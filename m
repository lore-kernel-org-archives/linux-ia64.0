From: Alexandre Ghiti <alex@ghiti.fr>
Date: Fri, 03 Aug 2018 09:47:10 +0000
Subject: Re: [PATCH v5 09/11] hugetlb: Introduce generic version of huge_ptep_set_wrprotect
Message-Id: <ef7fbd80-84a9-0b39-f948-413dea6f6469@ghiti.fr>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180731060155.16915-1-alex@ghiti.fr>
 <20180731060155.16915-10-alex@ghiti.fr>
 <87h8kfhg7o.fsf@concordia.ellerman.id.au>
 <6acb1389-6998-bafb-cf69-174fd522c04c@ghiti.fr>
 <90bf556f-144d-24b8-d2f6-70fee4a30559@ghiti.fr>
 <87muu3hlzc.fsf@concordia.ellerman.id.au>
In-Reply-To: <87muu3hlzc.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, mike.kravetz@oracle.com, linux@armlinux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com, tony.luck@intel.com, fenghua.yu@intel.com, ralf@linux-mips.org, paul.burton@mips.com, jhogan@kernel.org, jejb@parisc-linux.org, deller@gmx.de, benh@kernel.crashing.org, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, arnd@arndb.de, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, "aneesh.kumar@linux.ibm.com" <aneesh.kumar@linux.ibm.c>

Hi Michael,

Thanks, I will then remove those two specific implementations and we'll 
use the generic ones.

I send a v6 asap.

Thanks again,

Alex


On 08/03/2018 10:51 AM, Michael Ellerman wrote:
> Hi Alex,
>
> Sorry missed your previous mail.
>
> Alex Ghiti <alex@ghiti.fr> writes:
>> Ok, I tried every defconfig available:
>>
>> - for the nohash/32, I found that I could use mpc885_ads_defconfig and I
>> activated HUGETLBFS.
>> I removed the definition of huge_ptep_set_wrprotect from
>> nohash/32/pgtable.h, add an #error in
>> include/asm-generic/hugetlb.h right before the generic definition of
>> huge_ptep_set_wrprotect,
>> and fell onto it at compile-time:
>> => I'm pretty confident then that removing the definition of
>> huge_ptep_set_wrprotect does not
>> break anythingin this case.
> Thanks, that sounds good.
>
>> - regardind book3s/32, I did not find any defconfig with
>> CONFIG_PPC_BOOK3S_32, CONFIG_PPC32
>> allowing to enable huge page support (ie CONFIG_SYS_SUPPORTS_HUGETLBFS)
>> => Do you have a defconfig that would allow me to try the same as above ?
> I think you're right, it's dead code AFAICS.
>
> We have:
>
> config PPC_BOOK3S_64
>          ...
> 	select SYS_SUPPORTS_HUGETLBFS
>
> config PPC_FSL_BOOK3E
>          ...
> 	select SYS_SUPPORTS_HUGETLBFS if PHYS_64BIT || PPC64
>
> config PPC_8xx
> 	...
> 	select SYS_SUPPORTS_HUGETLBFS
>
>
> So we can't ever enable HUGETLBFS for Book3S 32.
>
> Presumably the code got copied when we split the headers apart.
>
> So I think you can just ignore that one, and we'll delete it.
>
> cheers

