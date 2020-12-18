From: Arnd Bergmann <arnd@kernel.org>
Date: Fri, 18 Dec 2020 22:07:26 +0000
Subject: Re: [PATCH v2 05/15] ia64: convert to legacy_timer_tick
Message-Id: <CAK8P3a0s5Wt=9sZXAV1JzebZFXVy4qn3KNvygEfPeH3eVMyO_w@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="0000000000006a616f05b6c456bf"
List-Id: <linux-ia64.vger.kernel.org>
References: <20201030151758.1241164-1-arnd@kernel.org> <20201030151758.1241164-6-arnd@kernel.org>
 <59efce0e-a28d-9424-82ca-fb7f3a1b9c29@physik.fu-berlin.de>
In-Reply-To: <59efce0e-a28d-9424-82ca-fb7f3a1b9c29@physik.fu-berlin.de>
To: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Arnd Bergmann <arnd@arndb.de>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Ungerer <gerg@linux-m68k.org>, Finn Thain <fthain@telegraphics.com.au>, Philip Blundell <philb@gnu.org>, Joshua Thompson <funaho@jurai.org>, Sam Creasey <sammy@sammy.net>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Daniel Lezcano <daniel.lezcano@linaro.org>, John Stultz <john.stultz@linaro.org>, Stephen Boyd <sboyd@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, linux-ia64@vger.kernel.org, Parisc List <linux-parisc@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Mike Rapoport <rppt@linux.ibm.com>, Anatoly Pugachev <matorola@gmail.com>

--0000000000006a616f05b6c456bf
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, Dec 18, 2020 at 10:29 PM John Paul Adrian Glaubitz
<glaubitz@physik.fu-berlin.de> wrote:
>
> Hi Arnd!
>
> On 10/30/20 4:17 PM, Arnd Bergmann wrote:
> > ia64 is the only architecture that calls xtime_update() in a loop,
> > once for each jiffie that has passed since the last event.
> >
> > Before commit 3171a0305d62 ("[PATCH] simplify update_times (avoid
> > jiffies/jiffies_64 aliasing problem)") in 2006, it could not actually d=
o
> > this any differently, but now it seems simpler to just pass the number
> > of jiffies that passed in the meantime.
> >
> > While this loses the ability process interrupts in the middle of
> > the timer tick by calling local_irq_enable(), doing so is fairly
> > peculiar anyway and it seems better to just do what everyone
> > else does here.
>
> This broke the hpsa block device driver on my HP RX2600.

Hi Adrian,

Sorry for causing this bug, and thank you for bisecting it
down to my patch.

Do you see any other strange behavior with that patch, or is
this the only symptom you are aware of?

>
> I'm seeing this backtrace now:
>
> [  905.883273] usb 1-2: SerialNumber: A60020000001
> [  905.918170]  sda: sda1 sda2 sda3
> [  905.920107] sd 0:1:0:0: [sda] Attached SCSI disk
> [  905.944102] usb-storage 1-2:1.0: USB Mass Storage device detected
> [  905.944102] scsi host1: usb-storage 1-2:1.0
> [  905.944102] usbcore: registered new interface driver usb-storage
> [  905.944117] usbcore: registered new interface driver uas

The timestamps show that time is moving forward, which is at least
something. Do you have a feeling for whether the timestamps are
counting in (roughly) the correct speed, or is it going much faster
or slower than it should?

To clarify: the [905.944117] numbers are seconds/microseconds
since boot, so message would be 906 seconds after the kernel
started.

> Begin: Loading essential drivers ... done.                               =
                                                                           =
              > Begin: Running /scripts/init-premount ... done.            =
                                                                           =
                          > Begin: Mounting root file system ... Begin: Run=
ning /scripts/local-top ... done.

Ok, so it gets into user space. Is this initramfs or the actual read-only r=
oot?

> [  906.666923] hpsa 0000:05:00.0: scsi 0:1:0:0: resetting logical  Direct=
-Access     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathCap- En- Exp=3D1
> [  906.670923] hpsa 0000:05:00.0: device is ready.
> [  906.670923] hpsa 0000:05:00.0: scsi 0:1:0:0: reset logical  completed =
successfully Direct-Access     HP       LOGICAL VOLUME   RAID-0 SSDSmartPat=
hCap- En- Exp=3D1
> done.
> [  906.722166] rcu: INFO: rcu_sched detected stalls on CPUs/tasks:
> [  906.722166] rcu:     2-....: (3 ticks this GP) idle=3Dfe6/1/0x40000000=
00000000 softirq=3D693/698 fqs=3D4
> [  906.722166]  (detected by 0, t=3D6115 jiffies, g=3D465, q=3D80)
This appears to be an 'rcu stall' warning, from print_cpu_stall_info(),
indicating that timer ticks are missing.

> [  909.360108] INFO: task systemd-sysv-ge:200 blocked for more than 127 s=
econds.
> [  909.360108]       Not tainted 5.10.0+ #130
> [  909.360108] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disable=
s this message.
> [  909.360108] task:systemd-sysv-ge state:D stack:    0 pid:  200 ppid:  =
 189 flags:0x00000000
> [  909.364108]
> [  909.364108] Call Trace:
> [  909.364423]  [<a00000010109b210>] __schedule+0x890/0x21e0
> [  909.364423]                                 sp=3De0000100487d7b70 bsp=
=3De0000100487d1748
> [  909.368423]  [<a00000010109cc00>] schedule+0xa0/0x240
> [  909.368423]                                 sp=3De0000100487d7b90 bsp=
=3De0000100487d16e0
> [  909.368558]  [<a00000010109ce70>] io_schedule+0x70/0xa0
> [  909.368558]                                 sp=3De0000100487d7b90 bsp=
=3De0000100487d16c0
> [  909.372290]  [<a00000010109e1c0>] bit_wait_io+0x20/0xe0
> [  909.372290]                                 sp=3De0000100487d7b90 bsp=
=3De0000100487d1698
> [  909.374168] rcu: INFO: rcu_sched detected stalls on CPUs/tasks:
> [  909.376290]  [<a00000010109d860>] __wait_on_bit+0xc0/0x1c0
> [  909.376290]                                 sp=3De0000100487d7b90 bsp=
=3De0000100487d1648
> [  909.374168] rcu:     3-....: (2 ticks this GP) idle=3D19e/1/0x40000000=
00000002 softirq=3D1581/1581 fqs=3D2
> [  909.374168]  (detected by 0, t=3D5661 jiffies, g=3D1089, q=3D3)
> [  909.376290]  [<a00000010109da80>] out_of_line_wait_on_bit+0x120/0x140
> [  909.376290]                                 sp=3De0000100487d7b90 bsp=
=3De0000100487d1610
> [  909.374168] Task dump for CPU 3:
> [  909.374168] task:khungtaskd      state:R  running task

and this seems to be another instance of the same. I would assume that this
is completely unrelated to the block driver and just happened to trigger du=
ring
the same time the driver was doing something.

Can you see in your full logs if the "Oops: timer tick before it's due" war=
ning
triggered at any point?

I've attached a patch for a partial revert of my original change, this
should still work with the final cleanup on top, but restore the loop
plus the local_irq_enable()/local_irq_disable() that I dropped from
the original code. Does this make a difference?

        Arnd

--0000000000006a616f05b6c456bf
Content-Type: text/x-patch; charset="US-ASCII"; name="ia64-timer-partial-revert.diff"
Content-Disposition: attachment; filename="ia64-timer-partial-revert.diff"
Content-Transfer-Encoding: base64
Content-ID: <f_kiutlz1y0>
X-Attachment-Id: f_kiutlz1y0

ZGlmZiAtLWdpdCBhL2FyY2gvaWE2NC9rZXJuZWwvdGltZS5jIGIvYXJjaC9pYTY0L2tlcm5lbC90
aW1lLmMKaW5kZXggOTQzMWVkYjA4NTA4Li5lM2Q5YzgwODhkNTYgMTAwNjQ0Ci0tLSBhL2FyY2gv
aWE2NC9rZXJuZWwvdGltZS5jCisrKyBiL2FyY2gvaWE2NC9rZXJuZWwvdGltZS5jCkBAIC0xNjEs
MjkgKzE2MSwzNCBAQCB2b2lkIHZ0aW1lX2FjY291bnRfaWRsZShzdHJ1Y3QgdGFza19zdHJ1Y3Qg
KnRzaykKIHN0YXRpYyBpcnFyZXR1cm5fdAogdGltZXJfaW50ZXJydXB0IChpbnQgaXJxLCB2b2lk
ICpkZXZfaWQpCiB7Ci0JdW5zaWduZWQgbG9uZyBjdXJfaXRtLCBuZXdfaXRtLCB0aWNrczsKKwl1
bnNpZ25lZCBsb25nIG5ld19pdG07CiAKIAlpZiAoY3B1X2lzX29mZmxpbmUoc21wX3Byb2Nlc3Nv
cl9pZCgpKSkgewogCQlyZXR1cm4gSVJRX0hBTkRMRUQ7CiAJfQogCiAJbmV3X2l0bSA9IGxvY2Fs
X2NwdV9kYXRhLT5pdG1fbmV4dDsKLQljdXJfaXRtID0gaWE2NF9nZXRfaXRjKCk7CiAKLQlpZiAo
IXRpbWVfYWZ0ZXIoY3VyX2l0bSwgbmV3X2l0bSkpIHsKKwlpZiAoIXRpbWVfYWZ0ZXIoaWE2NF9n
ZXRfaXRjKCksIG5ld19pdG0pKQogCQlwcmludGsoS0VSTl9FUlIgIk9vcHM6IHRpbWVyIHRpY2sg
YmVmb3JlIGl0J3MgZHVlIChpdGM9JWx4LGl0bT0lbHgpXG4iLAotCQkgICAgICAgY3VyX2l0bSwg
bmV3X2l0bSk7Ci0JCXRpY2tzID0gMTsKLQl9IGVsc2UgewotCQl0aWNrcyA9IERJVl9ST1VORF9V
UChjdXJfaXRtIC0gbmV3X2l0bSwKLQkJCQkgICAgIGxvY2FsX2NwdV9kYXRhLT5pdG1fZGVsdGEp
OwotCQluZXdfaXRtICs9IHRpY2tzICogbG9jYWxfY3B1X2RhdGEtPml0bV9kZWx0YTsKLQl9CisJ
CSAgICAgICBpYTY0X2dldF9pdGMoKSwgbmV3X2l0bSk7CisKKwl3aGlsZSAoMSkgeworCQluZXdf
aXRtICs9IGxvY2FsX2NwdV9kYXRhLT5pdG1fZGVsdGE7CisKKwkJbGVnYWN5X3RpbWVyX3RpY2so
c21wX3Byb2Nlc3Nvcl9pZCgpID09IHRpbWVfa2VlcGVyX2lkKTsKIAotCWlmIChzbXBfcHJvY2Vz
c29yX2lkKCkgIT0gdGltZV9rZWVwZXJfaWQpCi0JCXRpY2tzID0gMDsKKwkJbG9jYWxfY3B1X2Rh
dGEtPml0bV9uZXh0ID0gbmV3X2l0bTsKIAotCWxlZ2FjeV90aW1lcl90aWNrKHRpY2tzKTsKKwkJ
aWYgKHRpbWVfYWZ0ZXIobmV3X2l0bSwgaWE2NF9nZXRfaXRjKCkpKQorCQkJYnJlYWs7CisKKwkJ
LyoKKwkJICogQWxsb3cgSVBJcyB0byBpbnRlcnJ1cHQgdGhlIHRpbWVyIGxvb3AuCisJCSAqLwor
CQlsb2NhbF9pcnFfZW5hYmxlKCk7CisJCWxvY2FsX2lycV9kaXNhYmxlKCk7CisJfQogCiAJZG8g
ewogCQkvKgo=
--0000000000006a616f05b6c456bf--
