From: Tony Luck <tony.luck@gmail.com>
Date: Tue, 19 Mar 2013 23:13:00 +0000
Subject: Re: CMCI vector not initialized on BP
Message-Id: <CA+8MBbLXQp3-C5RAjNv0TgP24BUbY_Wv66DfR39ivyex0REePw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <D8D957864D852146A97B866681B1DF2F0D16C73A@G9W0768.americas.hpqcorp.net>
In-Reply-To: <D8D957864D852146A97B866681B1DF2F0D16C73A@G9W0768.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Fri, Mar 15, 2013 at 1:21 PM, Luck, Tony <tony.luck@intel.com> wrote:
> How about if we make sure that the relevent parts of
> ia64_mca_late_init() are run on CPU0.

To answer my own quesontion ... because it will splat all sorts of
ugly messages on the console. Like these:


WARNING: at kernel/mutex.c:199 __mutex_lock_slowpath+0x6d0/0x700()
Hardware name: I8QBH
Modules linked in:

Call Trace:
 [<a000000100016020>] show_stack+0x80/0xa0
                                sp=E000000301b5f620 bsp=E000000301b51530
 [<a000000100b36ad0>] dump_stack+0x30/0x50
                                sp=E000000301b5f7f0 bsp=E000000301b51518
 [<a000000100080920>] warn_slowpath_common+0xc0/0x100
                                sp=E000000301b5f7f0 bsp=E000000301b514d8
 [<a0000001000809a0>] warn_slowpath_null+0x40/0x60
                                sp=E000000301b5f7f0 bsp=E000000301b514b0
 [<a000000100b38ed0>] __mutex_lock_slowpath+0x6d0/0x700
                                sp=E000000301b5f7f0 bsp=E000000301b51420
 [<a000000100b38f30>] mutex_lock+0x30/0x60
                                sp=E000000301b5f810 bsp=E000000301b51400
 [<a0000001001495d0>] irq_reserve_irqs+0x90/0x140
                                sp=E000000301b5f810 bsp=E000000301b513c0
 [<a000000100152db0>] irq_set_chip+0xb0/0xe0
                                sp=E000000301b5f810 bsp=E000000301b51398
 [<a0000001000134b0>] ia64_native_register_percpu_irq+0xf0/0x1a0
                                sp=E000000301b5f820 bsp=E000000301b51368
 [<a000000100e0e650>] ia64_mca_late_init_bsp+0x20/0xf0
                                sp=E000000301b5fbf0 bsp=E000000301b51350
 [<a00000010011cff0>] generic_smp_call_function_single_interrupt+0x230/0x440
                                sp=E000000301b5fbf0 bsp=E000000301b51318
 [<a000000100067bc0>] handle_IPI+0x1a0/0x2a0
                                sp=E000000301b5fc00 bsp=E000000301b512c8

:-(

-Tony
