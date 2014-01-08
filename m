From: Mikael Pettersson <mikpelinux@gmail.com>
Date: Wed, 08 Jan 2014 08:33:43 +0000
Subject: Re: clock way too fast when running on the ski emulator
Message-Id: <21197.3431.396672.30352@gargle.gargle.HOWL>
List-Id: <linux-ia64.vger.kernel.org>
References: <21193.30525.139298.506962@gargle.gargle.HOWL>
In-Reply-To: <21193.30525.139298.506962@gargle.gargle.HOWL>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Mikael Pettersson writes:
 > When I run the ia64 kernel (3.12, CONFIG_IA64_HP_SIM=y) on ski (1.3.2,
 > x86_64 host with 3.13-rc6 kernel), the clock (as reported by `date`)
 > runs way too fast.  10 seconds on the host is reported as about 211
 > seconds in the guest, with about 6763 timer ticks delta in /proc/interrupts.
 > 
 > The output from /sbin/hwclock advances at the correct rate, however.
 > 
 > Any ideas what might be causing this?  Kernel bug or ski bug?

Answering my own question:

They're both buggy.

Ski is buggy for incrementing the ITC based on how fast it emulates
instructions, leading to an ITC frequency that is variable and mostly
a function of the host platform.

The kernel is buggy for inventing ITC-related SAL/PAL FREQ values
out of thin air, that have no relation whatsoever to the actual ITC
frequency in ski.

I'm going to implement a known-frequency ITC in ski.

/Mikael
