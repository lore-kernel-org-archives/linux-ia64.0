From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 13 Mar 2002 18:34:53 +0000
Subject: Re: [Linux-ia64] gcc/binutils bug building parted?
Message-Id: <marc-linux-ia64-105590701905259@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905246@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905246@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 13 Mar 2002 11:57:00 +0000, Richard Hirst <rhirst@linuxcare.com> said:

  Richard> Note there is no .align before that .LC26 label.  The last
  Richard> byte used in .rodata happens to be 0xe6, so r40 gets loaded
  Richard> with .rodata+0xe7, as can be seen if I disassemble the .o
  Richard> file:

  Richard>     1360: 09 40 01 02 00 24 [MMI] addl r40=0,r1 1360:
  Richard> LTOFF22 .rodata+0xe7

  Richard> That is all correct, I guess, but when I come to dump the
  Richard> .rodata section I see

  Richard>   d0: 30 39 3a 33 36 3a 34 31 20 62 75 79 74 65 6e 68
  Richard> 09:36:41 buytenh e0: 20 45 78 70 20 24 00 00 a2 a0 d0 eb e5
  Richard> b9 33 44 Exp $........3D f0: 87 c0 68 b6 b7 26 99 c7
  Richard> ..h..&..

  Richard> where you can see that the LC26 data is actually stored at
  Richard> .rodata+0xe8, not +0xe7.

Oh, I see now what's wrong: data4 implicitly aligns the data to a 4-byte
boundary.  To get an unaligned entry, you'd have to use data4.ua or gcc
would have to emit the data byte by byte (data1).

This needs to be fixed in the compiler.  Would you mind filing a bug
report with the gcc folks?

However, I also feel strongly the defining the efi_guid_t like this:

typedef struct {
        uint32_t time_low;
        uint16_t time_mid;
        uint16_t time_hi_and_version;
        uint8_t  clock_seq_hi_and_reserved;
        uint8_t  clock_seq_low;
        uint8_t  node[6];
} __attribute__ ((packed)) efi_guid_t;

is fundamentally broken, because it introduces byte-order dependency.
I'd recommend doing something along the following lines instead:

typedef unsigned char guid_t[16];
#define EFI_GUID(a,b,c,b0,b1,b2,b3,b4,b5,b6,b7)				 \
{ (a) & 0xff, ((a) >> 8) & 0xff, ((a) >> 16) & 0xff, ((a) >> 24) & 0xff, \
  (b) & 0xff, ((b) >> 8) & 0xff,					 \
  (c) & 0xff, ((c) >> 8) & 0xff,					 \
  (b0), (b1), (b2), (b3), (b4), (b5), (b6), (b7) }

This is untested, but I think you'll get the idea.  This should be
much better because it works independent of the host's byte-order and
doesn't require using gcc-only extensions to C.  It will also work
around the compiler bug until that gets fixed.

Now if only we could convince the EFI folks to do the same...

	--david

