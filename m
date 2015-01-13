From: Helge Deller <deller@gmx.de>
Date: Tue, 13 Jan 2015 21:11:34 +0000
Subject: Re: [PATCH 1/3] module_arch_freeing_init(): new hook for archs before module->module_init freed.
Message-Id: <54B58A06.5000800@gmx.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1420678687-30548-1-git-send-email-rusty@rustcorp.com.au> <1420678687-30548-2-git-send-email-rusty@rustcorp.com.au>
In-Reply-To: <1420678687-30548-2-git-send-email-rusty@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rusty Russell <rusty@rustcorp.com.au>, linux-kernel@vger.kernel.org
Cc: Chris Metcalf <cmetcalf@ezchip.com>, Haavard Skinnemoen <hskinnemoen@gmail.com>, Hans-Christian Egtvedt <egtvedt@samfundet.no>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-s390@vger.kernel.org

On 08.01.2015 01:58, Rusty Russell wrote:
> Archs have been abusing module_free() to clean up their arch-specific
> allocations.  Since module_free() is also (ab)used by BPF and trace code,
> let's keep it to simple allocations, and provide a hook called before
> that.
>
> This means that avr32, ia64, parisc and s390 no longer need to implement
> their own module_free() at all.  avr32 doesn't need module_finalize()
> either.
>
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Chris Metcalf <cmetcalf@ezchip.com>
> Cc: Haavard Skinnemoen <hskinnemoen@gmail.com>
> Cc: Hans-Christian Egtvedt <egtvedt@samfundet.no>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Fenghua Yu <fenghua.yu@intel.com>
> Cc: "James E.J. Bottomley" <jejb@parisc-linux.org>
> Cc: Helge Deller <deller@gmx.de>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-ia64@vger.kernel.org
> Cc: linux-parisc@vger.kernel.org
> Cc: linux-s390@vger.kernel.org
> ---
>   arch/avr32/kernel/module.c   | 13 +------------
>   arch/ia64/kernel/module.c    |  6 ++----
>   arch/parisc/kernel/module.c  |  6 +-----
>   arch/s390/kernel/module.c    | 10 +++-------
>   arch/tile/kernel/module.c    |  2 +-
>   include/linux/moduleloader.h |  2 ++
>   kernel/module.c              |  7 +++++++
>   7 files changed, 17 insertions(+), 29 deletions(-)

I successfully tested it on the parisc arch.

Acked-by: Helge Deller <deller@gmx.de>

Thanks!
Helge
