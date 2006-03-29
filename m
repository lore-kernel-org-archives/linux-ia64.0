From: Greg Edwards <edwardsg@sgi.com>
Date: Wed, 29 Mar 2006 19:01:30 +0000
Subject: Re: [Fedora-ia64-list] kernel 2.6.16-1.2097_FC6 unbootable on Itanium
Message-Id: <20060329190130.GE12830@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <442AB6DD.4020800@sgi.com>
In-Reply-To: <442AB6DD.4020800@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Mar 29, 2006 at 01:55:26PM -0500, Prarit Bhargava wrote:
| But it looks like it is hanging on Altix's at
| 
| Calling initcall 0xa0000001006ad230: bictcp_register+0x0/0x40()
| TCP bic registered
| Calling initcall 0xa0000001006b1160: xfrm_user_init+0x0/0xe0()
| Initializing IPsec netlink socket
| Calling initcall 0xa0000001006ade70: af_unix_init+0x0/0x120()
| NET: Registered protocol family 1
| Calling initcall 0xa0000001006adfc0: packet_init+0x0/0x100()
| NET: Registered protocol family 17
| Calling initcall 0xa0000001006a9670: acpi_poweroff_init+0x0/0x100()
| Calling initcall 0xa0000001006af2d0: seqgen_init+0x0/0x40()
| Calling initcall 0xa0000001006b18d0: early_uart_console_switch+0x0/0x120()
| Calling initcall 0xa0000001006a8e10: net_random_reseed+0x0/0x100()
| Freeing unused kernel memory: 400kB freed

Is it hung, or did it MCA?  Check the leds (ctrl-t to L2 from console,
then 'leds').  If you repeat this procedure, you should see the LED
values changing.

Greg
