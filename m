From: "H. Peter Anvin" <hpa@zytor.com>
Date: Mon, 04 Jan 2016 18:47:09 +0000
Subject: Re: [PATCH 6/6] arm64: switch to relative exception tables
Message-Id: <568ABE2D.9060207@zytor.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451837157-447-1-git-send-email-ard.biesheuvel@linaro.org> <1451837157-447-7-git-send-email-ard.biesheuvel@linaro.org> <20160104144643.GE1616@arm.com> <568AB65A.8030901@zytor.com> <3908561D78D1C84285E8C5FCA982C28F39FA127B@ORSMSX114.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F39FA127B@ORSMSX114.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "mingo@redhat.com" <mingo@redhat.com>, "heiko.carstens@de.ibm.com" <heiko.carstens@de.ibm.com>, "schwidefsky@de.ibm.com" <schwidefsky@de.ibm.com>, "mattst88@gmail.com" <mattst88@gmail.com>, "ink@jurassic.park.msu.ru" <ink@jurassic.park.msu.ru>, "rth@twiddle.net" <rth@twiddle.net>, "Yu, Fenghua" <fenghua.yu@intel.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "arnd@arndb.de" <arnd@arndb.de>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mark.rutland@arm.com" <mark.rutland@arm.com>, "marc.zyngier@arm.com" <marc.zyngier@arm.com>

On 01/04/2016 10:20 AM, Luck, Tony wrote:
>> May I humbly ask why the [Finnish] you don't use the equivalent of the
>> x86 _ASM_EXTABLE() macro?  In fact, why don't we make that one generic, too?
> 
> I'm messing with that right now (with help from Andy Lutomirski and Boris) to
> add different classes of exception table (so I can tag some instructions as being
> suitable for fixup from the machine check handler).  So it might not be generic
> for much longer.
> 
> http://marc.info/?l=linux-kernel&m5187079504846&w=2
> 

That doesn't mean it can't be overridden.

	-hpa


