From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 28 Mar 2001 22:26:40 +0000
Subject: Re: [Linux-ia64] Status of 64K pagesize support
Message-Id: <marc-linux-ia64-105590693005365@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005288@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005288@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 26 Mar 2001 11:51:07 -0600 (CST), Jack Steiner <steiner@sgi.com> said:

  Jack> Here is a summary of the changes I've made so far:

  Jack>   include/asm-ia64/system.h add BOOT_PARAM_ADDR. If pagesize
  Jack> is 64K, BOOT_PARAM_ADDR. is not the same as ZERO_PAGE_ADDR.

OK, sounds reasonable.  I made that change.

  Jack>   arch/ia64/boot/bootloader.c change name of ZERO_PAGE_ADDR to
  Jack> BOOT_PARAM_ADDR

OK.

  Jack>   arch/ia64/kernel/fw-emu.c change name of ZERO_PAGE_ADDR to
  Jack> BOOT_PARAM_ADDR

OK.

  Jack>   arch/ia64/kernel/gate.S delete ".align PAGE_SIZE". Code is
  Jack> already correctly aligned & gcc doesnt support alignment > 16k

I don't want to do that.  The .align is there to make it clear that
the code must be page aligned.  We should fix gas instead.

  Jack>   arch/ia64/kernel/ivt.S add alignment pragmas to the end to
  Jack> make the size of the IVT an integral number of pages.

I don't really like that.  The ivt shouldn't have to care what the
page size is.  I put an alignment directive in the linker script
instead.

  Jack>   arch/ia64/kernel/setup.c change name of ZERO_PAGE_ADDR to
  Jack> BOOT_PARAM_ADDR

OK.

  Jack>   arch/ia64/sn/fprom/fw-emu.c change name of ZERO_PAGE_ADDR to
  Jack> BOOT_PARAM_ADDR

OK.

  Jack>   drivers/scsi/scsi_dma.c change the FreeSectorBitmap so that
  Jack> on 64k page systems, a bit in the map represents 1K instead of
  Jack> 512 bytes. Otherwise, you overflow the long used to manage
  Jack> free space in a page.  I view this as an interim fix..... (I
  Jack> swapped mail with dugger about this patch).

I'll wait with this one until there is a permanent fix.

  Jack>   include/asm-ia64/a.out.h dont make STACK_TOP bigger than the
  Jack> max virtual address supported on itanium.

Ditto here.

	--david

