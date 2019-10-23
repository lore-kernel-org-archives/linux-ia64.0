From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 23 Oct 2019 21:30:29 +0000
Subject: RE: [PATCH 1/2] rtc/ia64: remove legacy efirtc driver
Message-Id: <3908561D78D1C84285E8C5FCA982C28F7F4AD7F7@ORSMSX115.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191023150311.844123-1-arnd@arndb.de>
 <20191023184616.GA17078@agluck-desk2.amr.corp.intel.com>
 <20191023200135.GT3125@piout.net>
In-Reply-To: <20191023200135.GT3125@piout.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alexandre Belloni <alexandre.belloni@bootlin.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "linux-rtc@vger.kernel.org" <linux-rtc@vger.kernel.org>, Alessandro Zummo <a.zummo@towertech.it>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "Yu, Fenghua" <fenghua.yu@intel.com>, Stephane Eranian <eranian@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

>> rtc-efi rtc-efi: setting system clock to 2019-10-23T18:30:23 UTC (1571855423)

> You can remove CONFIG_RTC_HCTOSYS, this line will disappear, systemd
> will not like that but efirtc was not setting the system time anyway so
> this shouldn't change the behaviour.


Wait ... that message says "setting system clock"

but then you say " efirtc was not setting the system time anyway".

So did the time get set, or not?

If it wasn't set, why does the message say that it was set?

-Tony
