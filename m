From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 05 Dec 2003 01:36:46 +0000
Subject: RE: can't boot 2.6.0-test11
Message-Id: <marc-linux-ia64-107058830818353@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107057525104512@msgid-missing>
In-Reply-To: <marc-linux-ia64-107057525104512@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

2.6.0-test11 boots fine on my tiger4 machine, with or without David's
test11-ia64-031126 patch.  Apparently the prime suspect of "percpu data
segment" doesn't do any damage to me.

My readelf -e looks like:
Program Headers:
  Type           Offset             VirtAddr           PhysAddr
                 FileSiz            MemSiz              Flags  Align
  LOAD           0x0000000000010000 0xa000000100000000
0x0000000004000000
                 0x00000000004eef20 0x00000000004eef20  R E    10000
  LOAD           0x0000000000500000 0xa0000001004f0000
0x00000000044f0000
                 0x0000000000088b00 0x0000000000088b00  RWE    10000
  LOAD           0x0000000000590000 0xffffffffffff0000
0x0000000004580000
                 0x00000000000081d0 0x00000000000081d0  RW     10000
  LOAD           0x00000000005a0000 0xa000000100590000
0x0000000004590000
                 0x00000000000625e4 0x0000000000096dd8  RW     10000
  IA_64_UNWIND   0x00000000004801b0 0xa0000001004701b0
0x00000000044701b0
                 0x0000000000025e18 0x0000000000025e18  R      8


Bill Nottingham (notting@redhat.com) said: 
>> > The AllocatePages() says you are trying to allocate
3377699721561477
>> > 4KB pages. Clearly not something you want. Is the output of readelf
-e
>> > on vmlinux decent?
>> 
>> As much as I can tell, it is. Not that that means much from me.
>
>Comparing readelf output, one big difference is where it loads the
>percpu data segment:
>
>2.6.0-test11:
>
>Program Headers:
> Type           Offset             VirtAddr           PhysAddr
>                FileSiz            MemSiz              Flags  Align
> LOAD           0x0000000000010000 0xa000000100000000
0x0000000004000000
>                0x00000000005a0c00 0x00000000005a0c00  RWE    10000
> LOAD           0x00000000005c0000 0xffffffffffff0000
0x00000000045b0000
>                0x00000000000084a8 0x00000000000084a8  RW     10000
> LOAD           0x00000000005d0000 0xa0000001005c0000
0x00000000045c0000
>                0x00000000000a3004 0x0000000000131e48  RW     10000
> IA_64_UNWIND   0x00000000004c8568 0xa0000001004b8568
0x00000000044b8568
>                0x0000000000029898 0x0000000000029898  R      8
