From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 04 Jan 2016 19:49:26 +0000
Subject: Re: [PATCH 6/6] arm64: switch to relative exception tables
Message-Id: <20160104194925.GA19213@agluck-desk.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451837157-447-1-git-send-email-ard.biesheuvel@linaro.org>
 <1451837157-447-7-git-send-email-ard.biesheuvel@linaro.org>
 <20160104144643.GE1616@arm.com>
 <568AB65A.8030901@zytor.com>
 <3908561D78D1C84285E8C5FCA982C28F39FA127B@ORSMSX114.amr.corp.intel.com>
 <568AC64A.4090601@zytor.com>
 <CAKv+Gu-n70=Kdf2NtygzYxEURO+Dnk1cmMX6D3gmXQ1E5-PHUA@mail.gmail.com>
In-Reply-To: <CAKv+Gu-n70=Kdf2NtygzYxEURO+Dnk1cmMX6D3gmXQ1E5-PHUA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Will Deacon <will.deacon@arm.com>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "mingo@redhat.com" <mingo@redhat.com>, "heiko.carstens@de.ibm.com" <heiko.carstens@de.ibm.com>, "schwidefsky@de.ibm.com" <schwidefsky@de.ibm.com>, "mattst88@gmail.com" <mattst88@gmail.com>, "ink@jurassic.park.msu.ru" <ink@jurassic.park.msu.ru>, "rth@twiddle.net" <rth@twiddle.net>, "Yu, Fenghua" <fenghua.yu@intel.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "arnd@arndb.de" <arnd@arndb.de>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mark.rutland@arm.com" <mark.rutland@arm.com>, "marc.zyngier@arm.com" <marc.zyngier@arm.com>

On Mon, Jan 04, 2016 at 08:28:52PM +0100, Ard Biesheuvel wrote:
> On 4 January 2016 at 20:21, H. Peter Anvin <hpa@zytor.com> wrote:
> > I suspect that means we will also need to go back to arch-specific
> > sorting for x86.
> >
> 
> AFAICT, Tony's patches are not incompatible with mine. The fixup
> address is offset with a large constant, but this does not affect the
> sort order (since that is based on the other member), and the swap
> operation that adds/subtracts the delta should not care about the
> class bits. (I don't see any changes to sort_extable() in Tony's
> patch)

Correct. Sorting is by the "insn" field (which I did not change).
The "fixup" field is just modified by an offset value, so survives
the math when moved to a new slot by the sort.

> @Tony: any comments? And do you have any objections to the ia64 patch
> in this series?
The ia64 bits look OK. I haven't tested, but add my Acked-by: anyway.

-Tony
