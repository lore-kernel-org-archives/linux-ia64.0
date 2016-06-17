From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 17 Jun 2016 21:39:00 +0000
Subject: RE: [PATCH] ia64: efi: use timespec64 for persistent clock
Message-Id: <3908561D78D1C84285E8C5FCA982C28F3A13F30B@ORSMSX114.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160617144920.3511152-1-arnd@arndb.de>
In-Reply-To: <20160617144920.3511152-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>, "Yu, Fenghua" <fenghua.yu@intel.com>
Cc: "y2038@lists.linaro.org" <y2038@lists.linaro.org>, Matt Fleming <matt@codeblueprint.co.uk>, Ingo Molnar <mingo@kernel.org>, Toshi Kani <toshi.kani@hpe.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

> Aside from this, we get a little closer to removing the
> __weak read_persistent_clock() definition, which relies on
> converting all architectures to provide read_persistent_clock64
> instead.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied. Thanks

-Tony
