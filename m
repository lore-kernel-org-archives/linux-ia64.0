From: peterc@gelato.unsw.edu.au
Date: Thu, 01 Jul 2004 00:09:31 +0000
Subject: Re: Using GDB kills kernel
Message-Id: <16611.22075.878736.592514@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <16610.19218.349114.463377@wombat.chubb.wattle.id.au>
In-Reply-To: <16610.19218.349114.463377@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

>>>>> "Alex" =3D Alex Williamson <alex.williamson@hp.com> writes:

Alex> On Wed, 2004-06-30 at 15:09 +1000, Peter Chubb wrote:
>>  With David's current patch against 2.6.7-BK, attempting to use GDB
>> causes a firmware assertion failure on my ZX2000.  Looks like it's
>> causing a SAL call or something.
>>=20
>> gdb ./h (gdb) r Firmware assertion failed: (((DATA8) addr - salNvm)
>> < NVM_SIZE) || (((DATA8) addr - efiNvm) < EFI_NVM_SIZE), file
>> bbsram_new.c line 570 ....
>>=20

Alex>    According to our firmware guys, that message is trying to say
Alex> that something tried to access non-volatile memory outside of
Alex> the SAL or EFI address ranges (ie. bad address that happened to
Alex> hit NVM).  I can't reproduce it on my box.  Does it happen every
Alex> time?  Any dependency on the binary gdb is debugging?  Thanks,


I can reproduce the problem on any one-processor Zx2000, when using
gdb on any process.

On a dual processor, I see an oops instead:

Unable to handle kernel paging request at virtual address
a00080a40bc4c008=20
gdb[426]: Oops 8821862825984 [1]=20
 =20
Call Trace:=20
 [<a000000100015b20>] show_stack+0x80/0xa0=20
                    sp=E000004040bd79a0 bsp=E000004040bd12e8=20
 [<a000000100024c90>] die+0x1f0/0x280=20
                    sp=E000004040bd7b70 bsp=E000004040bd12b0=20
 [<a00000010003fb40>] ia64_do_page_fault+0x360/0x960=20
                    sp=E000004040bd7b70 bsp=E000004040bd1248=20
 [<a00000010000e1a0>] ia64_leave_kernel+0x0/0x260=20
                    sp=E000004040bd7c00 bsp=E000004040bd1248=20
 [<a0000001000e0c40>] get_user_pages+0x980/0x9c0=20
                    sp=E000004040bd7dd0 bsp=E000004040bd10e8=20
 [<a000000100088f00>] access_process_vm+0x1a0/0x4e0=20
                    sp=E000004040bd7de0 bsp=E000004040bd1038=20
 [<a000000100018e50>] ia64_peek+0x230/0x260=20
                    sp=E000004040bd7e00 bsp=E000004040bd0fe0=20
 [<a00000010001c070>] sys_ptrace+0x390/0xb20=20
                    sp=E000004040bd7e20 bsp=E000004040bd0f48=20
 [<a00000010000e020>] ia64_ret_from_syscall+0x0/0x20=20
                    sp=E000004040bd7e30 bsp=E000004040bd0f48=20


0xa0000001000e0c40 where the fault occurred is=20
include/linux/mm.h:307 -- the atomic-increment of page->_count in
get_page.
--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
