From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 24 Jun 2010 17:11:46 +0000
Subject: RE: [bug report ] hp's rx2860 (kernel is 2.6.27.19-5 in sles11
Message-Id: <987664A83D2D224EAE907B061CE93D530144D3F2C2@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <201006242333018701088@tom.com>
In-Reply-To: <201006242333018701088@tom.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: bob_zhang2004 <bob_zhang2004@tom.com>, "Brown, Len" <len.brown@intel.com>
Cc: linux-ia64 <linux-ia64@vger.kernel.org>, linux-acpi <linux-acpi@vger.kernel.org>

> 4,  when I am debugging "acpi_enter_sleep_state()" , I found that this is > a tough task because after somewhat, I can't use printk() again .
> so I can't trace them defintely , do you have some better solution ???? 

Perhaps you could use the early_console code (you'd have to add some code
to switch back to it). Take a look at Documentation/ia64/serial.txt. That
code just pushes bytes out the serial port with very few dependencies, so
it ought to keep working till very late during shutdown sequence.

-Tony
