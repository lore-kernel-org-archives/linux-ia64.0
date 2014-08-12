From: Chen Gang <gang.chen.5i5j@gmail.com>
Date: Tue, 12 Aug 2014 03:27:42 +0000
Subject: Re: [PATCH] arch: Kconfig: Let all little endian architectures define CPU_LITTLE_ENDIAN explicitly
Message-Id: <53E989AE.7070808@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <53E93334.5000205@gmail.com> <20140811225326.GF30401@n2100.arm.linux.org.uk>
In-Reply-To: <20140811225326.GF30401@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Arnd Bergmann <arnd@arndb.de>, akpm@linux-foundation.org, Geert Uytterhoeven <geert@linux-m68k.org>, Jean Delvare <jdelvare@suse.de>, catalin.marinas@arm.com, will.deacon@arm.com, tony.luck@intel.com, fenghua.yu@intel.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, gxt@mprc.pku.edu.cn, liqin.linux@gmail.com, lennox.wu@gmail.com, cmetcalf@tilera.com, hskinnemoen@gmail.com, egtvedt@samfundet.no, james.hogan@imgtec.com, linux-arch@vger.kernel.org



On 8/12/14 6:53, Russell King - ARM Linux wrote:
> On Tue, Aug 12, 2014 at 05:18:44AM +0800, Chen Gang wrote:
>> x86, ia64, and arm(64) are little endian, and also another architectures
>> may be little endian (mips, sh, powerpc, and m32r) which already marked
>> CPU_LITTLE_ENDIAN explicitly.
> 
> This is incorrect.  ARM can be either endian.
> 
> arch/arm/mm/Kconfig:
> 
> config CPU_BIG_ENDIAN
>         bool "Build big-endian kernel"
>         depends on ARCH_SUPPORTS_BIG_ENDIAN
>         help
>           Say Y if you plan on running a kernel in big-endian mode.
>           Note that your board must be properly built and your board
>           port must properly enable any big-endian related features
>           of your chipset/board/processor.
> 

OK, thanks, I shall check all CPU_BIG_ENDIAN and send patch v2 for it.

And still welcome another ideas, suggestions or completions, especially
for another architectures.


Thanks.
-- 
Chen Gang

Open, share, and attitude like air, water, and life which God blessed
