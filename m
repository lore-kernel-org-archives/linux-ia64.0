From: Richard Hirst <rhirst@linuxcare.com>
Date: Wed, 13 Mar 2002 11:57:00 +0000
Subject: Re: [Linux-ia64] gcc/binutils bug building parted?
Message-Id: <marc-linux-ia64-105590701905256@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905246@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905246@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 12, 2002 at 09:01:01PM -0800, David Mosberger wrote:
> That is pretty weird.  Does the problem occur with gcc3 as well?  It might
> also help to look at the assembly code.

Yes, it does happen with gcc 3.0.4 as well, if I mess with a string
length in the .c source, to provoke it.  The problem seems to be related
to the packed attribute on the struct definition:

typedef struct {
        uint32_t time_low;
        uint16_t time_mid;
        uint16_t time_hi_and_version;
        uint8_t  clock_seq_hi_and_reserved;
        uint8_t  clock_seq_low;
        uint8_t  node[6];
} __attribute__ ((packed)) efi_guid_t;


When that is used thus:

#define PARTITION_BASIC_DATA_GUID \
    ((efi_guid_t) { 0xEBD0A0A2, 0xB9E5, 0x4433, 0x87, 0xC0, { 0x68, 0xB6, 0xB7, 0x26, 0x99, 0xC7 }})

                gpt_part_data->pte->PartitionTypeGuid                                 PARTITION_BASIC_DATA_GUID;


it generates assembler like this:

                .section        .rodata
.LC26:
        data4   3956318370
        data2   47589
        data2   17459
        data1   135
        data1   192
        data1   104
        data1   182
        data1   183
        data1   38
        data1   153
        data1   199
...
...
        addl r40 = @ltoff(.LC26), gp
...


Note there is no .align before that .LC26 label.  The last byte used in
.rodata happens to be 0xe6, so r40 gets loaded with .rodata+0xe7, as can
be seen if I disassemble the .o file:

    1360:       09 40 01 02 00 24       [MMI]       addl r40=0,r1
                        1360: LTOFF22   .rodata+0xe7

That is all correct, I guess, but when I come to dump the .rodata section
I see

  d0:   30 39 3a 33 36 3a 34 31 20 62 75 79 74 65 6e 68     09:36:41 buytenh
  e0:   20 45 78 70 20 24 00 00 a2 a0 d0 eb e5 b9 33 44      Exp $........3D
  f0:   87 c0 68 b6 b7 26 99 c7                             ..h..&..


where you can see that the LC26 data is actually stored at .rodata+0xe8,
not +0xe7.

If I remove the __attribute__ ((packed)), then the assembler has a .align 4
before .LC26, and things are ok.  It seems odd that strings in .rodata are
all .align 8, while this struct, even when not packed, is only .align 4.

It looks like the code generation assumes no .align to mean .align 1,
while the .rodata generation assumes no .align to mean .align 4.  Is
that possible?

Given that that struct is arranged with largest types first (as dictated
by the guid definition, of course), is there any reason to have a packed
attribute on it anyway?

The attached program will generate the problem for you; "ding" is 5 bytes
long so the generated code thinks the guid is at .rodata+5, while .rodata
is actually generated with the guid at .rodata+8.

Richard

---------------------------------- cut -------------------------------
typedef unsigned int uint32_t;
typedef unsigned short uint16_t;
typedef unsigned char uint8_t;

typedef struct {
        uint32_t time_low;
        uint16_t time_mid;
        uint16_t time_hi_and_version;
        uint8_t  clock_seq_hi_and_reserved;
        uint8_t  clock_seq_low;
        uint8_t  node[6];
} __attribute__ ((packed)) efi_guid_t;

#define PARTITION_BASIC_DATA_GUID \
    ((efi_guid_t) { 0xEBD0A0A2, 0xB9E5, 0x4433, 0x87, 0xC0, { 0x68, 0xB6, 0xB7, 0x26, 0x99, 0xC7 }})

void
bar (char **p)
{
        *p = "ding";
}

void
foo (efi_guid_t *g)
{
        *g = PARTITION_BASIC_DATA_GUID;
}

int
main (int argc, char **argv)
{
        efi_guid_t g;
        char *p;

        bar(&p);
        foo(&g);

        return 0;
}
---------------------------------- cut -------------------------------


