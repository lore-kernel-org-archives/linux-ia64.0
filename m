From: Keith Owens <kaos@ocs.com.au>
Date: Fri, 16 Feb 2001 23:57:38 +0000
Subject: Re: [Linux-ia64] Intermittent errors on mov rr
Message-Id: <marc-linux-ia64-105590693005166@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005157@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005157@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 16 Feb 2001 11:48:52 -0800,
David Mosberger <davidm@hpl.hp.com> wrote:
>Linux reads PAL_VM_SUMMARY and sets the limit accordingly.  On
>Itanium, the limit should be 0x8000-1 (18-3 bits) and that's what I
>see:
>
>	kdb> md ia64_ctx
>	e000000000abe6e8: 00000000 00006a02 00008000 00007fff  .....j.........
>						     ^^^^^^^^
>
>Keith, can you verify that you get the right value here as well?

[0]kdb> md ia64_ctx
0xe000000000a6c090 00000000 00000fdb 00007fff 001fffff

=> /proc/pal/cpu0/version_info <=
PAL_vendor : 0xff (min=0xff)
PAL_A      : 2.2.13 (min=2.2.13)
PAL_B      : 2.2.13 (min=2.0.0)

=> /proc/pal/cpu0/vm_info <=
Physical Address Space         : 44 bits
Virtual Address Space          : 51 bits
Protection Key Registers(PKR)  : 16
Implemented bits in PKR.key    : 24
Hash Tag ID                    : 0x1
Size of RR.rid                 : 24

Time to upgrade PAL.


