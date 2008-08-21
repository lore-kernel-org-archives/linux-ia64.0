From: Nishanth Aravamudan <nacc@us.ibm.com>
Date: Thu, 21 Aug 2008 21:31:46 +0000
Subject: Re: kernel unaligned accesses on IA64 in IDE
Message-Id: <20080821213146.GK11729@us.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080819225606.GB22088@us.ibm.com> <20080820143531.GA6488@sgi.com>
In-Reply-To: <20080820143531.GA6488@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Robin Holt <holt@sgi.com>
Cc: tony.luck@intel.com, bzolnier@gmail.com, linux-ia64@vger.kernel.org, linux-ide@vger.kernel.org

On 20.08.2008 [09:35:31 -0500], Robin Holt wrote:
> On Tue, Aug 19, 2008 at 03:56:06PM -0700, Nishanth Aravamudan wrote:
> > Hi Tony, Bart,
> > 
> > As mentioned in the cpu_clock() thread, I am seeing (consistently) 5
> > unaligned accesses in the bootlogs on a 2-node IA64 box:
> > 
> > [   32.593534] kernel unaligned access to 0xe000000644220466, ip=0xa000000100516fa1
> > [   32.601171] kernel unaligned access to 0xe00000064422046e, ip=0xa000000100516fa1
> > [   35.333273] kernel unaligned access to 0xe00000064451693e, ip=0xa000000100516fa1
> > [   35.340912] kernel unaligned access to 0xe000000644516942, ip=0xa000000100516fa1
> > [   35.348557] kernel unaligned access to 0xe000000644516946, ip=0xa000000100516fa1
> > 
> > Looking in the corresponding System.map, I see:
> > 
> > a000000100516940 T ide_input_data
> > a000000100516ec0 T ide_output_data
> > a000000100517340 T ide_execute_command
> > a000000100517420 t atapi_reset_pollfunc
> 
> I compiled your .config with commit ??? and got ide_output_data at
> a000000100516ae0 so the offending instruction is at a000000100516bc1
> 
> a000000100516bc0:       08 a8 00 4c 18 10       [MMI]       ld8 r21=[r38]
> a000000100516bc6:       d0 22 90 20 28 c0                   ld4 r45=[r36],4
> a000000100516bcc:       05 28 01 84                         mov r46=r37
> 
> Those look reasonable.

See my reply to Peter, but this seems the same as my results.

> That seems to be coming from include/asm/io.h:280
> 
> static inline void
> __outsl (unsigned long port, const void *src, unsigned long count)
> {
> 	const unsigned int *sp = src;
> 
> 	while (count--)
> 		platform_outl(*sp++, port);
> }
> 
> which is really outsl and that is only used on line 339:
> 			outsl(data_addr, buf, len / 4);

As does this.

> With as little as I know about what I am doing, I would probably add a
> printk immediately after the outsl line and dump out data_addr, buf,
> and len to see what those values are.  I expect either data_addr is
> not aligned on an 8 byte boundary or buf is not aligned on a 4 byte
> boundary.

Here's what I got, I put the printk() before the outsl() line, as I
don't believe the arguments are being manipulated?

[   32.597792] outsl(496, e000000644678466, 3)
[   32.602116] kernel unaligned access to 0xe000000644678466, ip=0xa0000001005174d1
[   32.609744] kernel unaligned access to 0xe00000064467846e, ip=0xa0000001005174d1
[   35.342053] outsl(496, e0000013041d693e, 3)
[   35.346388] kernel unaligned access to 0xe0000013041d693e, ip=0xa0000001005174d1
[   35.354016] kernel unaligned access to 0xe0000013041d6942, ip=0xa000000100517531
[   35.361633] kernel unaligned access to 0xe0000013041d6946, ip=0xa0000001005174d1
[   32.648053] outsl(496, e000000644678466, 3)
[   35.377343] outsl(496, e0000013041d693e, 3)
[   35.383999] outsl(496, e000001303fbd9c6, 3)
[   35.398650] outsl(496, e0000013041d693e, 3)
[   35.405287] outsl(496, e000001303fbd9c6, 3)
[   35.410586] outsl(496, e0000013041d693e, 3)
[   35.417489] outsl(496, e000001303fbd9c6, 3)
[   35.444091] outsl(496, e000001303fbd2a6, 3)
[   35.449121] outsl(496, e0000013041d693e, 3)
[   35.455748] outsl(496, e000001303fbd2a6, 3)
[   35.470427] outsl(496, e0000013041d693e, 3)
[   35.477141] outsl(496, e000001303fbd2a6, 3)
[   35.482305] outsl(496, e0000013041d693e, 3)
[   35.488964] outsl(496, e000001303fbd2a6, 3)
[   35.494232] outsl(496, e0000013041d693e, 3)
[   35.500912] outsl(496, e000001303fbd2a6, 3)


Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center
