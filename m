From: Kalle Valo <kvalo@kernel.org>
Date: Mon, 28 Mar 2022 12:06:51 +0000
Subject: Re: [PATCH 20/22] wireless: Replace comments with C99 initializers
Message-Id: <164846920750.11945.16978682699891961444.kvalo@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220326165909.506926-20-benni@stuerz.xyz>
In-Reply-To: <20220326165909.506926-20-benni@stuerz.xyz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: =?utf-8?q?Benjamin_St=C3=BCrz?= <benni@stuerz.xyz>
Cc: andrew@lunn.ch, sebastian.hesselbarth@gmail.com, gregory.clement@bootlin.com, linux@armlinux.org.uk, linux@simtec.co.uk, krzk@kernel.org, alim.akhtar@samsung.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, hpa@zytor.com, robert.moore@intel.com, rafael.j.wysocki@intel.com, lenb@kernel.org, 3chas3@gmail.com, laforge@gnumonks.org, arnd@arndb.de, gregkh@linuxfoundation.org, mchehab@kernel.org, tony.luck@intel.com, james.morse@arm.com, rric@kernel.org, linus.walleij@linaro.org, brgl@bgdev.pl, mike.marciniszyn@cornelisnetworks.com, dennis.dalessandro@cornelisnetworks.com, jgg@ziepe.ca, pali@kernel.org, dmitry.torokhov@gmail.com, isdn@linux-pingi.de, benh@kernel.crashing.org, fbarrat@linux.ibm.com, ajd@linux.ibm.com, davem@davemloft.net, kuba@kernel.org, pabeni@redhat.com, nico@fluxnic.net, loic.poulain@linaro.org, pkshih@realtek.com, bhelgaas@google.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org, linux-edac@vger.kernel.org, linux-gpio@vger.kernel.org, linux-rdma@vger.kernel.org, linux-input@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-media@vger.kernel.org, wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org, linux-pci@vger.kernel.org, =?utf-8?q?Benjamin_St=C3=BCrz?= <benni@stuerz.xyz>

Benjamin Stürz <benni@stuerz.xyz> wrote:

> This replaces comments with C99's designated
> initializers because the kernel supports them now.
> 
> Signed-off-by: Benjamin Stürz <benni@stuerz.xyz>

The title prefix should be "ray_cs: ".

Patch set to Changes Requested.

-- 
https://patchwork.kernel.org/project/linux-wireless/patch/20220326165909.506926-20-benni@stuerz.xyz/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
