From: Cary Coutant <cary@cup.hp.com>
Date: Tue, 17 Oct 2000 22:40:06 +0000
Subject: Re: [Linux-ia64] avoiding float underflow software assist
Message-Id: <marc-linux-ia64-105590678205585@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205556@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205556@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>There's this method of masking just the control bits of sf0 into sf* if
>you'd rather not provide direct library access to the fpsr.  E.g., to
>set ftz in s0:
>
>    asm volatile("fsetc.s0 0x7f, 0x01");
>
>Or dup s0 into s2:
>
>    asm volatile("fsetc.s2 0x7f, 0x00");
>
>Not sure if/why intel gave us this instruction.  Perhaps switching speed
>is important to some apps.

This is definitely your best approach to setting the ftz bit:

    fsetc.s0 0x7f,0x01
    fsetc.s2 0,0x40
    fsetc.s3 0,0x40

This instruction is there to facilitate keeping the control bits of sf2 
and sf3 in sync with those of sf0, as mandated by the runtime 
architecture document. It makes it very easy for the compiler to change a 
control bit temporarily in sf2 or sf3 for one operation or a few, then 
restore it to its proper state.

Note the 0x40 when setting sf2 and sf3 -- the td (trap disable) bits 
should be set for these status fields (also mandated by the runtime 
architecture document).

-cary

