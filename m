From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Wed, 08 Jul 2020 07:18:35 +0000
Subject: Re: [PATCH RESENT] ia64: configs: Remove useless UEVENT_HELPER_PATH
Message-Id: <20200708071835.GA353684@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200707205030.32394-1-krzk@kernel.org>
In-Reply-To: <20200707205030.32394-1-krzk@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Krzysztof Kozlowski <krzk@kernel.org>
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Jul 07, 2020 at 10:50:30PM +0200, Krzysztof Kozlowski wrote:
> Remove the CONFIG_UEVENT_HELPER_PATH because:
> 1. It is disabled since commit 1be01d4a5714 ("driver: base: Disable
>    CONFIG_UEVENT_HELPER by default") as its dependency (UEVENT_HELPER) was
>    made default to 'n',
> 2. It is not recommended (help message: "This should not be used today
>    [...] creates a high system load") and was kept only for ancient
>    userland,
> 3. Certain userland specifically requests it to be disabled (systemd
>    README: "Legacy hotplug slows down the system and confuses udev").
> 
> Signed-off-by: Krzysztof Kozlowski <krzk@kernel.org>
> Acked-by: Geert Uytterhoeven <geert+renesas@glider.be>

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
