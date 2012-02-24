From: David Miller <davem@davemloft.net>
Date: Fri, 24 Feb 2012 20:42:24 +0000
Subject: Re: [PATCH 00/11] print MAC via printk format specifier
Message-Id: <20120224.154224.992364563810018486.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1330091162-8141-1-git-send-email-danny.kukawka@bisect.de>
In-Reply-To: <1330091162-8141-1-git-send-email-danny.kukawka@bisect.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: danny.kukawka@bisect.de
Cc: grundler@parisc-linux.org, gregkh@linuxfoundation.org, pe1dnn@amsat.org, kernel@wantstofly.org, marek.belisko@gmail.com, oneukum@suse.de, dkukawka@suse.de, devel@driverdev.osuosl.org, e1000-devel@lists.sourceforge.net, geert@linux-m68k.org, grant.likely@secretlab.ca, jkosina@suse.cz, jpirko@redhat.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org, netdev@vger.kernel.org, tklauser@distanz.ch

From: Danny Kukawka <danny.kukawka@bisect.de>
Date: Fri, 24 Feb 2012 14:45:51 +0100

> Print MAC/dev_addr via printk extended format specifier %pm/%pM
> instead of using custom code.
> 
> These patches are against net-next.

All applied, but you absolutely have to start posting patch series
correctly.

If it's a series for net-next, then every single patch must be
CC:'d to netdev so it gets queued up properly in patchwork.
