From: "Hartnett, Fred" <fred.hartnett@hp.com>
Date: Wed, 20 Mar 2013 12:49:33 +0000
Subject: RE: CMCI vector not initialized on BP
Message-Id: <D8D957864D852146A97B866681B1DF2F0D1799C9@G4W3207.americas.hpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <D8D957864D852146A97B866681B1DF2F0D16C73A@G9W0768.americas.hpqcorp.net>
In-Reply-To: <D8D957864D852146A97B866681B1DF2F0D16C73A@G9W0768.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi Tony - I tried a similar experiment of...

	smp_call_function_single(0, ia64_mca_cmc_vector_setup, NULL, 0);

in ia64_mca_late_init and the kernel hung with and without the wait flag (f=
orth argument) set.

I was thinking about the problem from a different angle. We know the BP is =
always cpu0, and it does not go through smp_callin like the APs. But at som=
e point during the boot, the kernel gets assigned to one seemingly random c=
pu (it changes each time I boot the kernel). Seems to me if we forced the k=
ernel to always run on cpu0, then by the time it gets to ia64_mca_late_init=
, the proper vector initialization would occur via the...

	ia64_mca_cmc_vector_setup();       /* Setup vector on BSP */

call. Question is how/where is the kernel thread assigned to a cpu number? =
I can see the advantage of floating the kernel thread to any available cpu =
in the event another cpu does not come online. So perhaps the default is fo=
rce to cpu0 if online, otherwise any available cpu. The user has other prob=
lems to deal with if a cpu does not initialize. Thoughts about this approac=
h?


Thanks - Fred


-----Original Message-----
From: Tony Luck [mailto:tony.luck@gmail.com]=20
Sent: Tuesday, March 19, 2013 6:13 PM
To: Hartnett, Fred
Cc: linux-ia64@vger.kernel.org
Subject: Re: CMCI vector not initialized on BP

On Fri, Mar 15, 2013 at 1:21 PM, Luck, Tony <tony.luck@intel.com> wrote:
> How about if we make sure that the relevent parts of
> ia64_mca_late_init() are run on CPU0.

To answer my own quesontion ... because it will splat all sorts of ugly mes=
sages on the console. Like these:


WARNING: at kernel/mutex.c:199 __mutex_lock_slowpath+0x6d0/0x700()
Hardware name: I8QBH
Modules linked in:

Call Trace:
 [<a000000100016020>] show_stack+0x80/0xa0
                                sp=E000000301b5f620 bsp=E000000301b51530  [=
<a000000100b36ad0>] dump_stack+0x30/0x50
                                sp=E000000301b5f7f0 bsp=E000000301b51518  [=
<a000000100080920>] warn_slowpath_common+0xc0/0x100
                                sp=E000000301b5f7f0 bsp=E000000301b514d8  [=
<a0000001000809a0>] warn_slowpath_null+0x40/0x60
                                sp=E000000301b5f7f0 bsp=E000000301b514b0  [=
<a000000100b38ed0>] __mutex_lock_slowpath+0x6d0/0x700
                                sp=E000000301b5f7f0 bsp=E000000301b51420  [=
<a000000100b38f30>] mutex_lock+0x30/0x60
                                sp=E000000301b5f810 bsp=E000000301b51400  [=
<a0000001001495d0>] irq_reserve_irqs+0x90/0x140
                                sp=E000000301b5f810 bsp=E000000301b513c0  [=
<a000000100152db0>] irq_set_chip+0xb0/0xe0
                                sp=E000000301b5f810 bsp=E000000301b51398  [=
<a0000001000134b0>] ia64_native_register_percpu_irq+0xf0/0x1a0
                                sp=E000000301b5f820 bsp=E000000301b51368  [=
<a000000100e0e650>] ia64_mca_late_init_bsp+0x20/0xf0
                                sp=E000000301b5fbf0 bsp=E000000301b51350  [=
<a00000010011cff0>] generic_smp_call_function_single_interrupt+0x230/0x440
                                sp=E000000301b5fbf0 bsp=E000000301b51318  [=
<a000000100067bc0>] handle_IPI+0x1a0/0x2a0
                                sp=E000000301b5fc00 bsp=E000000301b512c8

:-(

-Tony
