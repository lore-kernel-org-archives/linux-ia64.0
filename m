From: William Lee Irwin III <wli@holomorphy.com>
Date: Tue, 03 Aug 2004 16:48:36 +0000
Subject: Re: apparent sn_console deadlock
Message-Id: <20040803164836.GA2334@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040803105949.GX2334@holomorphy.com>
In-Reply-To: <20040803105949.GX2334@holomorphy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday, August 3, 2004 3:59 am, William Lee Irwin III wrote:
>> Bootlog (altix.log.7.gz) and .config attached. Also attached is a
>> bootlog from a small attempt not to switch out of sal_console_early
>> (altix.log.9.gz) i.e. bailing out of sn_sal_serial_console_init()
>> immediately without registering or unregistering consoles or doing
>> anything.

On Tue, Aug 03, 2004 at 08:55:16AM -0700, Jesse Barnes wrote:
> Your first log indicates that you're passing 'console=ttyS0' to the kernel at 
> boot time.  As of 2.6.8-rc2 (IIRC) you need to pass 'console=ttySG0' instead.  
> You'll also want to create a new character device, /dev/ttySG0 with major 
> 204, minor 40.
> I wasn't able to see the config file you attached, but I think you've 
> correctly turned on the SGI L1 console support (in the serial drivers section 
> of the character devices menu of Kconfig).

After console=ttySG0, making the device node, and removing the debug
hack of keeping the early SAL console, everything works now.

Thanks.

-- wli
