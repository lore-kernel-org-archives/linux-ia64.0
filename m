From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 23 Oct 2019 18:46:16 +0000
Subject: Re: [PATCH 1/2] rtc/ia64: remove legacy efirtc driver
Message-Id: <20191023184616.GA17078@agluck-desk2.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191023150311.844123-1-arnd@arndb.de>
In-Reply-To: <20191023150311.844123-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Alexandre Belloni <alexandre.belloni@bootlin.com>, linux-rtc@vger.kernel.org, Alessandro Zummo <a.zummo@towertech.it>, linux-ia64@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, Stephane Eranian <eranian@google.com>, linux-kernel@vger.kernel.org

On Wed, Oct 23, 2019 at 05:01:58PM +0200, Arnd Bergmann wrote:
> There are two EFI RTC drivers, the original drivers/char/efirtc.c
> driver and the more modern drivers/rtc/rtc-efi.c.
> 
> Both implement the same interface, but the new one does so
> in a more portable way.
> 
> Move everything over to that one and remove the old one.

The new one is more talkative that the old one. I see this extra
line on the console when I boot ia64:

rtc-efi rtc-efi: setting system clock to 2019-10-23T18:30:23 UTC (1571855423)

That seems somewhat useful & informative (though the repeated "rtc-efi"
at the start of the line is redundant).

Acked-by: Tony Luck <tony.luck@intel.com>

-Tony
