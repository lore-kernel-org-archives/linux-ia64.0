From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 14 Nov 2003 15:46:38 +0000
Subject: Re: drivers/usb/core/config.c: invalid configuration descriptor
Message-Id: <marc-linux-ia64-106882482525057@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106865176701709@msgid-missing>
In-Reply-To: <marc-linux-ia64-106865176701709@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 14 Nov 2003 14:03:04 +0100, Andreas Schwab <schwab@suse.de> said:

  Andreas> Andreas Schwab <schwab@suse.de> writes:
  >> When I try to run 2.6.0-test9 on an HP Everest I can't get USB
  >> working.  All I get is this:

  >> drivers/usb/core/usb.c: registered new driver hub PCI: Found IRQ
  >> 52 for device 0000:01:04.0 IOSAPIC: vector 52 -> CPU 0x0200,
  >> enabled ohci_hcd 0000:01:04.0: OHCI Host Controller ohci_hcd
  >> 0000:01:04.0: irq 52, pci mem c000000088032000 ohci_hcd
  >> 0000:01:04.0: new USB bus registered, assigned bus number 1
  >> drivers/usb/core/config.c: invalid configuration descriptor

  Andreas> This is actually a compiler bug, usb_parse_configuration
  Andreas> gets miscompiled.

Interesting.  Which compiler?

	--david
