From: Linus Walleij <linus.walleij@linaro.org>
Date: Sun, 27 Mar 2022 12:03:24 +0000
Subject: Re: [PATCH 09/22] gpio-winbond: Use C99 initializers
Message-Id: <CACRpkdYa6cKC34MzkXKsVSAFEkcGb=R5a0XS68eA3njoTh8Q8A@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220326165909.506926-1-benni@stuerz.xyz> <20220326165909.506926-9-benni@stuerz.xyz>
In-Reply-To: <20220326165909.506926-9-benni@stuerz.xyz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: =?UTF-8?Q?Benjamin_St=C3=BCrz?= <benni@stuerz.xyz>
Cc: andrew@lunn.ch, sebastian.hesselbarth@gmail.com, gregory.clement@bootlin.com, linux@armlinux.org.uk, linux@simtec.co.uk, krzk@kernel.org, alim.akhtar@samsung.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, hpa@zytor.com, robert.moore@intel.com, rafael.j.wysocki@intel.com, lenb@kernel.org, 3chas3@gmail.com, laforge@gnumonks.org, arnd@arndb.de, gregkh@linuxfoundation.org, mchehab@kernel.org, tony.luck@intel.com, james.morse@arm.com, rric@kernel.org, brgl@bgdev.pl, mike.marciniszyn@cornelisnetworks.com, dennis.dalessandro@cornelisnetworks.com, jgg@ziepe.ca, pali@kernel.org, dmitry.torokhov@gmail.com, isdn@linux-pingi.de, benh@kernel.crashing.org, fbarrat@linux.ibm.com, ajd@linux.ibm.com, davem@davemloft.net, kuba@kernel.org, pabeni@redhat.com, nico@fluxnic.net, loic.poulain@linaro.org, kvalo@kernel.org, pkshih@realtek.com, bhelgaas@google.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org, linux-edac@vger.kernel.org, linux-gpio@vger.kernel.org, linux-rdma@vger.kernel.org, linux-input@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-media@vger.kernel.org, wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org, linux-pci@vger.kernel.org

On Sat, Mar 26, 2022 at 6:00 PM Benjamin Stürz <benni@stuerz.xyz> wrote:

> This replaces comments with C99's designated
> initializers because the kernel supports them now.
>
> Signed-off-by: Benjamin Stürz <benni@stuerz.xyz>

Reviewed-by: Linus Walleij <linus.walleij@linaro.org>

Yours,
Linus Walleij
