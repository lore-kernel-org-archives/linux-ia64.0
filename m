From: Keith Owens <kaos@sgi.com>
Date: Mon, 24 Feb 2003 02:01:10 +0000
Subject: [Linux-ia64] Re: strange performance behaviour with floats
Message-Id: <marc-linux-ia64-105590709805912@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805910@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805910@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, 23 Feb 2003 17:50:41 -0800, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>>>>>> On Mon, 24 Feb 2003 12:45:10 +1100, Keith Owens <kaos@sgi.com> said:
>
>  Keith> generated a two bundle loop as you suggested, but BogoMIPS went down,
>  Keith> not up.
>
>Note: 2 bundle != 2 cycle, but even ignoring that: what did you
>expect?  BogoMIPS counts 2 instructions per loop iteration no matter
>how many instructions are being executed.  Perhaps you can get the
>compiler to unroll the loop.  Then you'd see a higher BogoMIPS.

Which loop needs unrolling?  __delay generates

     2d0:       11 00 00 00 01 00       [MIB]       nop.m 0x0
     2d6:       00 70 04 55 00 00                   mov.i ar.lc=r14
     2dc:       00 00 00 20                         nop.b 0x0;;
     2e0:       11 00 00 00 01 00       [MIB]       nop.m 0x0
     2e6:       00 00 00 02 00 a0                   nop.i 0x0
     2ec:       00 00 00 40                         br.cloop.sptk.few 2e0 <calibrate_delay+0x100>;;

br.cloop is already a single bundle loop.


