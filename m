From: "H. Peter Anvin" <hpa@zytor.com>
Date: Mon, 04 Jan 2016 18:13:46 +0000
Subject: Re: [PATCH 6/6] arm64: switch to relative exception tables
Message-Id: <568AB65A.8030901@zytor.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451837157-447-1-git-send-email-ard.biesheuvel@linaro.org> <1451837157-447-7-git-send-email-ard.biesheuvel@linaro.org> <20160104144643.GE1616@arm.com>
In-Reply-To: <20160104144643.GE1616@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org, mingo@redhat.com, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, mattst88@gmail.com, ink@jurassic.park.msu.ru, rth@twiddle.net, tony.luck@intel.com, fenghua.yu@intel.com, catalin.marinas@arm.com, arnd@arndb.de, akpm@linux-foundation.org, mark.rutland@arm.com, marc.zyngier@arm.com

On 01/04/2016 06:46 AM, Will Deacon wrote:
> On Sun, Jan 03, 2016 at 05:05:57PM +0100, Ard Biesheuvel wrote:
>> Instead of using absolute addresses for both the exception location
>> and the fixup, use offsets relative to the exception table entry values.
>> Not only does this cut the size of the exception table in half, it is
>> also a prerequisite for KASLR, since absolute exception table entries
>> are subject to dynamic relocation, which is incompatible with the sorting
>> of the exception table that occurs at build time.
>>
>> Cc: Catalin Marinas <catalin.marinas@arm.com>
>> Cc: Will Deacon <will.deacon@arm.com>
>> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
>> ---
>>
>> Note that this patch supersedes the version I sent as part of the series that
>> implements KASLR for arm64: http://thread.gmane.org/gmane.linux.kernel/2116531
>>
>>  arch/arm64/include/asm/assembler.h   |  2 +-
>>  arch/arm64/include/asm/futex.h       |  4 ++--
>>  arch/arm64/include/asm/uaccess.h     | 18 ++++++++++--------
>>  arch/arm64/kernel/armv8_deprecated.c |  4 ++--
>>  arch/arm64/mm/extable.c              |  2 +-
>>  scripts/sortextable.c                |  2 +-
>>  6 files changed, 17 insertions(+), 15 deletions(-)
> 
> This looks good to me, so for the arm64 part (i.e. this patch):
> 
>   Acked-by: Will Deacon <will.deacon@arm.com>

May I humbly ask why the [Finnish] you don't use the equivalent of the
x86 _ASM_EXTABLE() macro?  In fact, why don't we make that one generic, too?

	-hpa


