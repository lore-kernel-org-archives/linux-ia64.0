From: Alexandre Ghiti <alex@ghiti.fr>
Date: Fri, 27 Jul 2018 06:51:51 +0000
Subject: Re: [PATCH v4 00/11] hugetlb: Factorize hugetlb architecture primitives
Message-Id: <a6d158b6-965d-7473-677d-13a9b7d46ba1@ghiti.fr>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180705110716.3919-1-alex@ghiti.fr>
 <20180709141621.GD22297@dhcp22.suse.cz>
 <2173685f-7f85-7acb-4685-2383210c5fa2@ghiti.fr>
 <75195a7d-3d0f-4e55-92cc-4ad772683c75@oracle.com>
 <87tvomgqyv.fsf@concordia.ellerman.id.au>
 <99473e0d-12d8-bbea-fe9c-4e3738ab7f5a@oracle.com>
In-Reply-To: <99473e0d-12d8-bbea-fe9c-4e3738ab7f5a@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Kravetz <mike.kravetz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@kernel.org>
Cc: linux@armlinux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com, tony.luck@intel.com, fenghua.yu@intel.com, ralf@linux-mips.org, paul.burton@mips.com, jhogan@kernel.org, jejb@parisc-linux.org, deller@gmx.de, benh@kernel.crashing.org, paulus@samba.org, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, arnd@arndb.de, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>

Hi Mike,

Thanks for your review. I'm going to fix the 2nd patch as you said, 
you're right, no need to move the #include at the bottom of the file.
I'm going to post a v5, add -mm in cc and ask for inclusion in their tree.

Thanks again for your time,

Alex


On 07/26/2018 09:16 PM, Mike Kravetz wrote:
> On 07/26/2018 04:46 AM, Michael Ellerman wrote:
>> Mike Kravetz <mike.kravetz@oracle.com> writes:
>>
>>> On 07/20/2018 11:37 AM, Alex Ghiti wrote:
>>>> Does anyone have any suggestion about those patches ?
>>> I only took a quick look.  From the hugetlb perspective, I like the
>>> idea of moving routines to a common file.  If any of the arch owners
>>> (or anyone else) agree, I can do a review of the series.
>> The conversions look pretty good to me. If you want to give it a review
>> then from my point of view it could go in -mm to shake out any bugs.
> Nothing of significance found in a review.  As others have suggested,
> the (cross)compiler may be better at finding issues than human eyes.
>
> I also suggest it be added to -mm.

