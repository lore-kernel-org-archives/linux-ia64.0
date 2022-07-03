From: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Sun, 03 Jul 2022 15:04:58 +0000
Subject: Re: [PATCH v3 7/8] genirq: Return a const cpumask from irq_data_get_affinity_mask
Message-Id: <CAHp75VccKxO+Gtw46GvxSiPo4ShfpaZPOBehAp6gCoq3gT_9Cw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220701200056.46555-1-samuel@sholland.org> <20220701200056.46555-8-samuel@sholland.org>
In-Reply-To: <20220701200056.46555-8-samuel@sholland.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Samuel Holland <samuel@sholland.org>
Cc: Marc Zyngier <maz@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Bartosz Golaszewski <brgl@bgdev.pl>, Bjorn Helgaas <bhelgaas@google.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Borislav Petkov <bp@alien8.de>, Broadcom internal kernel review list <bcm-kernel-feedback-list@broadcom.com>, Chris Zankel <chris@zankel.net>, Colin Ian King <colin.king@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Dexuan Cui <decui@microsoft.com>, Florian Fainelli <f.fainelli@gmail.com>, Guo Ren <guoren@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Haiyang Zhang <haiyangz@microsoft.com>, Helge Deller <deller@gmx.de>, Ingo Molnar <mingo@redhat.com>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Jan Beulich <jbeulich@suse.com>, Joerg Roedel <joro@8bytes.org>, Juergen Gross <jgross@suse.com>, Julia Lawall <Julia.Lawall@inria.fr>, "K. Y. Srinivasan" <kys@microsoft.com>, Kees Cook <keescook@chromium.org>, =?UTF-8?Q?Krzysztof_Wilczy=C5=84ski?= <kw@linux.com>, Linus Walleij <linus.walleij@linaro.org>, Lorenzo Pieralisi <lpieralisi@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, Maximilian Heyne <mheyne@amazon.de>, Oleksandr Tyshchenko <oleksandr_tyshchenko@epam.com>, Rich Felker <dalias@libc.org>, Richard Henderson <rth@twiddle.net>, Rikard Falkeborn <rikard.falkeborn@gmail.com>, Rob Herring <robh@kernel.org>, Russell King <linux@armlinux.org.uk>, Serge Semin <fancer.lancer@gmail.com>, Stefano Stabellini <sstabellini@kernel.org>, Stephen Hemminger <sthemmin@microsoft.com>, Sven Schnelle <svens@stackframe.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Wei Liu <wei.liu@kernel.org>, Wei Xu <xuwei5@hisilicon.com>, Will Deacon <will@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, "list@263.net:IOMMU DRIVERS" <iommu@lists.linux-foundation.org>, iommu@lists.linux.dev, linux-alpha@vger.kernel.org, linux-arm Mailing List <linux-arm-kernel@lists.infradead.org>, Linux on Hyper-V List <linux-hyperv@vger.kernel.org>, linux-ia64@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, linux-parisc@vger.kernel.org, linux-pci <linux-pci@vger.kernel.org>, Linux-SH <linux-sh@vger.kernel.org>, linux-xtensa@linux-xtensa.org, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, xen-devel@lists.xenproject.org

On Fri, Jul 1, 2022 at 10:01 PM Samuel Holland <samuel@sholland.org> wrote:
>
> Now that the irq_data_update_affinity helper exists, enforce its use
> by returning a a const cpumask from irq_data_get_affinity_mask.
>
> Since the previous commit already updated places that needed to call
> irq_data_update_affinity, this commit updates the remaining code that
> either did not modify the cpumask or immediately passed the modified
> mask to irq_set_affinity.

When we refer to functions, we use parentheses, e.g. func().

-- 
With Best Regards,
Andy Shevchenko
