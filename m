From: Martin Pool <mbp@sourcefrog.net>
Date: Thu, 15 Apr 2004 02:35:24 +0000
Subject: Re: oops in serial_out in 2.6.5
Message-Id: <pan.2004.04.15.02.35.21.177650@sourcefrog.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040413063757.GA11350@hp.com>
In-Reply-To: <20040413063757.GA11350@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 14 Apr 2004 09:25:38 -0600, Bjorn Helgaas wrote:

> On Tuesday 13 April 2004 5:55 pm, Martin Pool wrote:
>> /dev/ttyS0 uart 16550A port 0x0000 irq 59 baud_base 115200 spd_normal skip_test
>> auto_irq
>> /dev/ttyS1 uart 16550A port 0x0000 irq 60 baud_base 115200 spd_normal skip_test
>> auto_irq
>> /dev/ttyS2 uart 16550A port 0x0000 irq 57 baud_base 115200 spd_normal skip_test
>> /dev/ttyS3 uart 16550A port 0x0000 irq 57 baud_base 115200 spd_normal skip_test
>> /dev/ttyS4 uart 16550A port 0x0000 irq 57 baud_base 115200 spd_normal skip_test
>> /dev/ttyS5 uart 16550A port 0x0000 irq 57 baud_base 115200 spd_normal skip_test
> 
> Notice that setserial is missing some smarts about MMIO UARTS (see
> the "port 0x0000" above).  I poked at this a while back, but it seemed
> sort of ugly to fix, IIRC.  Removing setserial seemed to be the
> easiest workaround.

I have done that, and filed a plea for Debian to stop making it autorun,
#243841.

I see the same request has been open for hppa for >6 months though. :-(

-- 
Martin

