From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 03 Aug 2004 15:55:16 +0000
Subject: Re: apparent sn_console deadlock
Message-Id: <200408030855.16905.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040803105949.GX2334@holomorphy.com>
In-Reply-To: <20040803105949.GX2334@holomorphy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday, August 3, 2004 3:59 am, William Lee Irwin III wrote:
> I seem to be having trouble around the switchover from sal_console_early
> to sal_console on an Altix with 2.6.8-rc2-mm2. As I've been out of the
> ia64 loop for a while, I figured it might be good to check in and see
> if this is a known issue or some easily-recognizable gaffe before going
> through too much trouble to debug it.
>
> The apparent failure mode is some kind of deadlock and/or loss of
> console output. Userspace doesn't make progress to normal booting (as
> it would if the console were merely misdirected), though it's not
> directly observable. system logs and other indicators show no trace
> of userspace having run on 2.6.8-rc2-mm2.
>
> Bootlog (altix.log.7.gz) and .config attached. Also attached is a
> bootlog from a small attempt not to switch out of sal_console_early
> (altix.log.9.gz) i.e. bailing out of sn_sal_serial_console_init()
> immediately without registering or unregistering consoles or doing
> anything.

Your first log indicates that you're passing 'console=ttyS0' to the kernel at 
boot time.  As of 2.6.8-rc2 (IIRC) you need to pass 'console=ttySG0' instead.  
You'll also want to create a new character device, /dev/ttySG0 with major 
204, minor 40.

I wasn't able to see the config file you attached, but I think you've 
correctly turned on the SGI L1 console support (in the serial drivers section 
of the character devices menu of Kconfig).

Jesse
