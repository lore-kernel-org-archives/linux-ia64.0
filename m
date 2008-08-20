From: Robin Holt <holt@sgi.com>
Date: Wed, 20 Aug 2008 14:35:31 +0000
Subject: Re: kernel unaligned accesses on IA64 in IDE
Message-Id: <20080820143531.GA6488@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080819225606.GB22088@us.ibm.com>
In-Reply-To: <20080819225606.GB22088@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: tony.luck@intel.com, bzolnier@gmail.com, linux-ia64@vger.kernel.org, linux-ide@vger.kernel.org

On Tue, Aug 19, 2008 at 03:56:06PM -0700, Nishanth Aravamudan wrote:
> Hi Tony, Bart,
> 
> As mentioned in the cpu_clock() thread, I am seeing (consistently) 5
> unaligned accesses in the bootlogs on a 2-node IA64 box:
> 
> [   32.593534] kernel unaligned access to 0xe000000644220466, ip=0xa000000100516fa1
> [   32.601171] kernel unaligned access to 0xe00000064422046e, ip=0xa000000100516fa1
> [   35.333273] kernel unaligned access to 0xe00000064451693e, ip=0xa000000100516fa1
> [   35.340912] kernel unaligned access to 0xe000000644516942, ip=0xa000000100516fa1
> [   35.348557] kernel unaligned access to 0xe000000644516946, ip=0xa000000100516fa1
> 
> Looking in the corresponding System.map, I see:
> 
> a000000100516940 T ide_input_data
> a000000100516ec0 T ide_output_data
> a000000100517340 T ide_execute_command
> a000000100517420 t atapi_reset_pollfunc

I compiled your .config with commit ??? and got ide_output_data at
a000000100516ae0 so the offending instruction is at a000000100516bc1

a000000100516bc0:       08 a8 00 4c 18 10       [MMI]       ld8 r21=[r38]
a000000100516bc6:       d0 22 90 20 28 c0                   ld4 r45=[r36],4
a000000100516bcc:       05 28 01 84                         mov r46=r37

Those look reasonable.

That seems to be coming from include/asm/io.h:280

static inline void
__outsl (unsigned long port, const void *src, unsigned long count)
{
	const unsigned int *sp = src;

	while (count--)
		platform_outl(*sp++, port);
}

which is really outsl and that is only used on line 339:
			outsl(data_addr, buf, len / 4);

With as little as I know about what I am doing, I would probably add a
printk immediately after the outsl line and dump out data_addr, buf, and
len to see what those values are.  I expect either data_addr is not
aligned on an 8 byte boundary or buf is not aligned on a 4 byte
boundary.

Keep in mind that I may have completely messed up my analysis and I am
pursuing the wrong line entirely.


Good Luck,
Robin
