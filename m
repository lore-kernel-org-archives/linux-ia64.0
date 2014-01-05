From: Mikael Pettersson <mikpelinux@gmail.com>
Date: Sun, 05 Jan 2014 15:16:13 +0000
Subject: clock way too fast when running on the ski emulator
Message-Id: <21193.30525.139298.506962@gargle.gargle.HOWL>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

When I run the ia64 kernel (3.12, CONFIG_IA64_HP_SIM=y) on ski (1.3.2,
x86_64 host with 3.13-rc6 kernel), the clock (as reported by `date`)
runs way too fast.  10 seconds on the host is reported as about 211
seconds in the guest, with about 6763 timer ticks delta in /proc/interrupts.

The output from /sbin/hwclock advances at the correct rate, however.

Any ideas what might be causing this?  Kernel bug or ski bug?

/Mikael
