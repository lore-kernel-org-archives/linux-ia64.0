From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Date: Mon, 11 Aug 2014 22:53:26 +0000
Subject: Re: [PATCH] arch: Kconfig: Let all little endian architectures define CPU_LITTLE_ENDIAN explicitly
Message-Id: <20140811225326.GF30401@n2100.arm.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <53E93334.5000205@gmail.com>
In-Reply-To: <53E93334.5000205@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Chen Gang <gang.chen.5i5j@gmail.com>
Cc: Arnd Bergmann <arnd@arndb.de>, akpm@linux-foundation.org, Geert Uytterhoeven <geert@linux-m68k.org>, Jean Delvare <jdelvare@suse.de>, catalin.marinas@arm.com, will.deacon@arm.com, tony.luck@intel.com, fenghua.yu@intel.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Aug 12, 2014 at 05:18:44AM +0800, Chen Gang wrote:
> x86, ia64, and arm(64) are little endian, and also another architectures
> may be little endian (mips, sh, powerpc, and m32r) which already marked
> CPU_LITTLE_ENDIAN explicitly.

This is incorrect.  ARM can be either endian.

arch/arm/mm/Kconfig:

config CPU_BIG_ENDIAN
        bool "Build big-endian kernel"
        depends on ARCH_SUPPORTS_BIG_ENDIAN
        help
          Say Y if you plan on running a kernel in big-endian mode.
          Note that your board must be properly built and your board
          port must properly enable any big-endian related features
          of your chipset/board/processor.

-- 
FTTC broadband for 0.8mile line: currently at 9.5Mbps down 400kbps up
according to speedtest.net.
