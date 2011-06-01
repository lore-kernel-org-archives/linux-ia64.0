From: Tony Luck <tony.luck@intel.com>
Date: Wed, 01 Jun 2011 21:07:11 +0000
Subject: Re: [PATCH] ia64: Hook up gpiolib support
Message-Id: <BANLkTi=CKNh_fm_zJFLM8PX5FWVeksgJRQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1306921697-31045-1-git-send-email-broonie@opensource.wolfsonmicro.com>
In-Reply-To: <1306921697-31045-1-git-send-email-broonie@opensource.wolfsonmicro.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jun 1, 2011 at 1:25 PM, Mark Brown
<broonie@opensource.wolfsonmicro.com> wrote:
> Allow people to use gpiolib on ia64, mostly for build coverage as it
> seems more useful to standardise on availablity of the API than handle
> it being optional.

Well it applies cleanly, builds too. I can even turn on CONFIG_GPIOLIB=y,
CONFIG_DEBUG_GPIO=y and CONFIG_GPIO_SYSFS=y and build even
more bits (no warnings, nice).

But is there anything that I can do with it to show that it is working
correctly?

-Tony
