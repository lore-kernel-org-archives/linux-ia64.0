From: Paul Burton <paul.burton@mips.com>
Date: Mon, 15 Apr 2019 17:19:11 +0000
Subject: Re: [PATCH] [v2] arch: add pidfd and io_uring syscalls everywhere
Message-Id: <20190415171910.ezhsqmncj2eiw7cc@pburton-laptop>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190415143007.2989285-1-arnd@arndb.de>
In-Reply-To: <20190415143007.2989285-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Heiko Carstens <heiko.carstens@de.ibm.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Michal Simek <monstr@monstr.eu>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Martin Schwidefsky <s>

Hi Arnd,

On Mon, Apr 15, 2019 at 04:22:57PM +0200, Arnd Bergmann wrote:
> Add the io_uring and pidfd_send_signal system calls to all architectures.
> 
> These system calls are designed to handle both native and compat tasks,
> so all entries are the same across architectures, only arm-compat and
> the generic tale still use an old format.
> 
> Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)
> Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com> (s390)
> Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
> Changes since v1:
> - fix s390 table
> - use 'n64' tag in mips-n64 instead of common.

Thanks for taking care of this:

  Acked-by: Paul Burton <paul.burton@mips.com> # MIPS

Thanks,
    Paul
