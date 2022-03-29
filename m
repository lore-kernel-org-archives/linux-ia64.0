From: Bartosz Golaszewski <brgl@bgdev.pl>
Date: Tue, 29 Mar 2022 12:30:40 +0000
Subject: Re: [PATCH 09/22] gpio-winbond: Use C99 initializers
Message-Id: <CAMRc=Md5qTnP1ZYak4f3hyqmaOR6jT_KL=rNr5cwAOcZ22yXfg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220326165909.506926-1-benni@stuerz.xyz> <20220326165909.506926-9-benni@stuerz.xyz>
In-Reply-To: <20220326165909.506926-9-benni@stuerz.xyz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: =?UTF-8?Q?Benjamin_St=C3=BCrz?= <benni@stuerz.xyz>
Cc: Andrew Lunn <andrew@lunn.ch>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>, Gregory Clement <gregory.clement@bootlin.com>, Russell King <linux@armlinux.org.uk>, linux@simtec.co.uk, Krzysztof Kozlowski <krzk@kernel.org>, alim.akhtar@samsung.com, Thomas Gleixner <tglx@linutronix.de>, mingo@redhat.com, Borislav Petkov <bp@alien8.de>, dave.hansen@linux.intel.com, hpa@zytor.com, robert.moore@intel.com, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, lenb@kernel.org, 3chas3@gmail.com, laforge@gnumonks.org, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Mauro Carvalho Chehab <mchehab@kernel.org>, Tony Luck <tony.luck@intel.com>, James Morse <james.morse@arm.com>, Robert Richter <rric@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, mike.marciniszyn@cornelisnetworks.com, dennis.dalessandro@cornelisnetworks.com, jgg@ziepe.ca, pali@kernel.org, Dmitry Torokhov <dmitry.torokhov@gmail.com>, isdn@linux-pingi.de, Benjamin Herrenschmidt <benh@kernel.crashing.org>, fbarrat@linux.ibm.com, ajd@linux.ibm.com, "David S . Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, nico@fluxnic.net, loic.poulain@linaro.org, kvalo@kernel.org, pkshih@realtek.com, Bjorn Helgaas <bhelgaas@google.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-samsung-soc@vger.kernel.org, linux-ia64@vger.kernel.org, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, devel@acpica.org, linux-atm-general@lists.sourceforge.net, netdev <netdev@vger.kernel.org>, linux-edac@vger.kernel.org, "open list:GPIO SUBSYSTEM" <linux-gpio@vger.kernel.org>, linux-rdma@vger.kernel.org, Linux Input <linux-input@vger.kernel.org>, linuxppc-dev@lists.ozlabs.org, Linux Media Mailing List <linux-media@vger.kernel.org>, wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org, linux-pci@vger.kernel.org

On Sat, Mar 26, 2022 at 6:00 PM Benjamin Stürz <benni@stuerz.xyz> wrote:
>
> This replaces comments with C99's designated
> initializers because the kernel supports them now.
>
> Signed-off-by: Benjamin Stürz <benni@stuerz.xyz>
> ---
>  drivers/gpio/gpio-winbond.c | 12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/gpio/gpio-winbond.c b/drivers/gpio/gpio-winbond.c
> index 7f8f5b02e31d..0b637fdb407c 100644
> --- a/drivers/gpio/gpio-winbond.c
> +++ b/drivers/gpio/gpio-winbond.c
> @@ -249,7 +249,7 @@ struct winbond_gpio_info {
>  };
>
>  static const struct winbond_gpio_info winbond_gpio_infos[6] = {
> -       { /* 0 */
> +       [0] = {
>                 .dev = WB_SIO_DEV_GPIO12,
>                 .enablereg = WB_SIO_GPIO12_REG_ENABLE,
>                 .enablebit = WB_SIO_GPIO12_ENABLE_1,
> @@ -266,7 +266,7 @@ static const struct winbond_gpio_info winbond_gpio_infos[6] = {
>                         .warnonly = true
>                 }
>         },
> -       { /* 1 */
> +       [1] = {
>                 .dev = WB_SIO_DEV_GPIO12,
>                 .enablereg = WB_SIO_GPIO12_REG_ENABLE,
>                 .enablebit = WB_SIO_GPIO12_ENABLE_2,
> @@ -277,7 +277,7 @@ static const struct winbond_gpio_info winbond_gpio_infos[6] = {
>                 .datareg = WB_SIO_GPIO12_REG_DATA2
>                 /* special conflict handling so doesn't use conflict data */
>         },
> -       { /* 2 */
> +       [2] = {
>                 .dev = WB_SIO_DEV_GPIO34,
>                 .enablereg = WB_SIO_GPIO34_REG_ENABLE,
>                 .enablebit = WB_SIO_GPIO34_ENABLE_3,
> @@ -294,7 +294,7 @@ static const struct winbond_gpio_info winbond_gpio_infos[6] = {
>                         .warnonly = true
>                 }
>         },
> -       { /* 3 */
> +       [3] = {
>                 .dev = WB_SIO_DEV_GPIO34,
>                 .enablereg = WB_SIO_GPIO34_REG_ENABLE,
>                 .enablebit = WB_SIO_GPIO34_ENABLE_4,
> @@ -311,7 +311,7 @@ static const struct winbond_gpio_info winbond_gpio_infos[6] = {
>                         .warnonly = true
>                 }
>         },
> -       { /* 4 */
> +       [4] = {
>                 .dev = WB_SIO_DEV_WDGPIO56,
>                 .enablereg = WB_SIO_WDGPIO56_REG_ENABLE,
>                 .enablebit = WB_SIO_WDGPIO56_ENABLE_5,
> @@ -328,7 +328,7 @@ static const struct winbond_gpio_info winbond_gpio_infos[6] = {
>                         .warnonly = true
>                 }
>         },
> -       { /* 5 */
> +       [5] = {
>                 .dev = WB_SIO_DEV_WDGPIO56,
>                 .enablereg = WB_SIO_WDGPIO56_REG_ENABLE,
>                 .enablebit = WB_SIO_WDGPIO56_ENABLE_6,
> --
> 2.35.1
>

Acked-by: Bartosz Golaszewski <brgl@bgdev.pl>
