From: Alexandre Belloni <alexandre.belloni@bootlin.com>
Date: Wed, 23 Oct 2019 20:01:35 +0000
Subject: Re: [PATCH 1/2] rtc/ia64: remove legacy efirtc driver
Message-Id: <20191023200135.GT3125@piout.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191023150311.844123-1-arnd@arndb.de>
 <20191023184616.GA17078@agluck-desk2.amr.corp.intel.com>
In-Reply-To: <20191023184616.GA17078@agluck-desk2.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-rtc@vger.kernel.org, Alessandro Zummo <a.zummo@towertech.it>, linux-ia64@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, Stephane Eranian <eranian@google.com>, linux-kernel@vger.kernel.org

On 23/10/2019 11:46:16-0700, Luck, Tony wrote:
> On Wed, Oct 23, 2019 at 05:01:58PM +0200, Arnd Bergmann wrote:
> > There are two EFI RTC drivers, the original drivers/char/efirtc.c
> > driver and the more modern drivers/rtc/rtc-efi.c.
> > 
> > Both implement the same interface, but the new one does so
> > in a more portable way.
> > 
> > Move everything over to that one and remove the old one.
> 
> The new one is more talkative that the old one. I see this extra
> line on the console when I boot ia64:
> 
> rtc-efi rtc-efi: setting system clock to 2019-10-23T18:30:23 UTC (1571855423)
> 
> That seems somewhat useful & informative (though the repeated "rtc-efi"
> at the start of the line is redundant).
> 

You can remove CONFIG_RTC_HCTOSYS, this line will disappear, systemd
will not like that but efirtc was not setting the system time anyway so
this shouldn't change the behaviour.

The redundancy in the log is kind of specific to this RTC. For CMOS,
this is: rtc_cmos 00:01, it should identify the RTC uniquely.

> Acked-by: Tony Luck <tony.luck@intel.com>
> 
> -Tony

-- 
Alexandre Belloni, Bootlin
Embedded Linux and Kernel engineering
https://bootlin.com
