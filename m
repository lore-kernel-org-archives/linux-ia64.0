From: "Sluder, Charles" <Charles.Sluder@UNISYS.com>
Date: Fri, 14 Feb 2003 18:33:30 +0000
Subject: RE: [Linux-ia64] Problem with elilo 3.3a
Message-Id: <marc-linux-ia64-105590709805855@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805846@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805846@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thank you. That helps.

The corruption is occurring before the kernel starts executing. Just a guess
but it looks like the code that loaded the kernel may of stepped on the
firmware table.

This is a dump of the EFI memory map made with an ITP before the kernel
started executing.

-chuck


[P3]>ord8 r28 4
0x00000010fef9a008L ia64  00000010fef9df9e 000000007fa082e0
0x00000010fef9a018L ia64  00000010fef8c008 0000000000000630

[P3]>char 0x10fef8c008 256
0x00000010fef8c008L ia64  '................................................'
0x00000010fef8c038L ia64  '................................................'
0x00000010fef8c068L ia64  '..........................................shstrt'
0x00000010fef8c098L ia64  '....text................@...............__ksymta'
0x00000010fef8c0c8L ia64  '....A_64.................C..............ta..kstr'
0x00000010fef8c0f8L ia64  '.....opd..@.............;...............it..init'
0x00000010fef8c128L ia64  '.....ini................................data.cac'
0x00000010fef8c158L ia64  '....ne_a..t.............!...............bss.....'
0x00000010fef8c188L ia64  '................................................'
0x00000010fef8c1b8L ia64  '................................................'
0x00000010fef8c1e8L ia64  '........................:.......................'
0x00000010fef8c218L ia64  '........................f.......................'
0x00000010fef8c248L ia64  '......................'

[P3]>ord8 0x10fef8c008 128
0x00000010fef8c008L ia64  0000000000000004 0000000000000000
0x00000010fef8c018L ia64  0000000000000000 0000000000000001
0x00000010fef8c028L ia64  0000000000000009 0000000000000000
0x00000010fef8c038L ia64  0000000000000007 0000000000001000
0x00000010fef8c048L ia64  0000000000000000 0000000000000089
0x00000010fef8c058L ia64  0000000000000009 0000000000000000
0x00000010fef8c068L ia64  0000000000000004 000000000008a000
0x00000010fef8c078L ia64  0000000000000000 0000000000000016
0x00000010fef8c088L ia64  0000000000000009 7472747368732e00
0x00000010fef8c098L ia64  7478657400000005 00000000000c0000
0x00000010fef8c0a8L ia64  0000000000000000 0000000000000040
0x00000010fef8c0b8L ia64  8000000000000009 61746d79736b5f5f
0x00000010fef8c0c8L ia64  34365f4100000007 0000000000100000
0x00000010fef8c0d8L ia64  0000000000000000 0000000000004300
0x00000010fef8c0e8L ia64  0000000000000009 7274736b2e006174
0x00000010fef8c0f8L ia64  64706f2e00000002 0000000004400000
0x00000010fef8c108L ia64  0000000000000000 000000000000073b
0x00000010fef8c118L ia64  0000000000000009 74696e692e007469
0x00000010fef8c128L ia64  696e692e00000007 0000000004b3b000
0x00000010fef8c138L ia64  0000000000000000 000000000007ac10
0x00000010fef8c148L ia64  0000000000000009 6361632e61746164
0x00000010fef8c158L ia64  615f656e00000006 000000007f74b000
0x00000010fef8c168L ia64  0000000000000000 0000000000000421
0x00000010fef8c178L ia64  8000000000000009 0000000000737362
0x00000010fef8c188L ia64  0000000000000006 000000007fb6c000
0x00000010fef8c198L ia64  0000000000000000 0000000000000004
0x00000010fef8c1a8L ia64  8000000000000009 0000000000000000
0x00000010fef8c1b8L ia64  0000000000000006 000000007fb70000
0x00000010fef8c1c8L ia64  0000000000000000 0000000000000090
0x00000010fef8c1d8L ia64  8000000000000009 0000000000010000
0x00000010fef8c1e8L ia64  000000000000000d 000000007fc00000
0x00000010fef8c1f8L ia64  0000000000000000 000000000000003a
0x00000010fef8c208L ia64  8000000000000009 0000000000000006
0x00000010fef8c218L ia64  e000000000000007 000000007fc3a000
0x00000010fef8c228L ia64  0000000000000000 0000000000000266
0x00000010fef8c238L ia64  0000000000000009 0000000000000000
0x00000010fef8c248L ia64  0000000100000005 000000007fea0000
0x00000010fef8c258L ia64  0000000000000000 0000000000000008
0x00000010fef8c268L ia64  8000000000000009 0000000000000000

-----Original Message-----
From: David Mosberger [mailto:davidm@napali.hpl.hp.com]
Sent: Friday, February 14, 2003 12:35 AM
To: eranian@hpl.hp.com
Cc: linux-ia64@linuxia64.org; David Mosberger
Subject: Re: [Linux-ia64] Problem with elilo 3.3a


>>>>> On Thu, 13 Feb 2003 23:28:28 -0800, Stephane Eranian
<eranian@frankl.hpl.hp.com> said:

  Stephane> The bootloader obtains the memory map from EFI. The map is
  Stephane> stored into a region specifically allocated by elilo. The
  Stephane> bootparam structure passes the address of the table and
  Stephane> its size to the kernel.

Ah, that's how I thought it worked.  I misunderstood your previous
mail (on re-reading it, it's clear though... ;-).

Thanks,

	--david

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

