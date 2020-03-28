From: afzal mohammed <afzal.mohd.ma@gmail.com>
Date: Sat, 28 Mar 2020 07:44:53 +0000
Subject: Re: [PATCH 0/6] Kill setup_irq()
Message-Id: <20200328073253.GA5250@afzalpc>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200321174303.GA7930@afzalpc>
 <cover.1585320721.git.afzal.mohd.ma@gmail.com>
 <059b01d604ab$637355b0$2a5a0110$@codeaurora.org>
In-Reply-To: <059b01d604ab$637355b0$2a5a0110$@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Brian Cain <bcain@codeaurora.org>
Cc: linux-s390@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-ia64@vger.kernel.org, linux-c6x-dev@linux-c6x.org, linux-parisc@vger.kernel.org, linux-sh@vger.kernel.org, linux-hexagon@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mips@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-alpha@vger.kernel.org, 'Thomas Gleixner' <tglx@linutronix.de>, linux-omap@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org

Hi Brian,

On Fri, Mar 27, 2020 at 09:48:38PM -0500, Brian Cain wrote:

> > Note 2: hexagon final image creation fails even w/o my patch

> 	What's the nature of the failure in "Note 2"?

drivers/base/firmware_loader/main.o: In function `fw_is_builtin_firmware':
/devel/src/kernel6/drivers/base/firmware_loader/main.c:132:(.text+0xc8): relocation truncated to fit: R_HEX_16_X against symbol `__start_builtin_fw' defined in .modinfo section in .tmp_vmlinux1
Makefile:1077: recipe for target 'vmlinux' failed
make: *** [vmlinux] Error 1

[ i had deleted the toolchain earlier, since you asked, download again &
checked ]

Regards
afzal
