From: Jes Sorensen <jes@linuxcare.com>
Date: Thu, 12 Oct 2000 16:13:15 +0000
Subject: Re: [Linux-ia64] avoiding float underflow software assist
Message-Id: <marc-linux-ia64-105590678205565@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205556@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205556@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Pete" = Pete Wyckoff <pw@osc.edu> writes:

Pete> jes@linuxcare.com said:
>>  We discussed this recently and David strongly opted for glibc
>> setting s2/s3 the same way we set s0. I need to look closer at this
>> in order to figure out how to deal with the get-then-set case but I
>> think it's coming.

Pete> There's this method of masking just the control bits of sf0 into
Pete> sf* if you'd rather not provide direct library access to the
Pete> fpsr.  E.g., to set ftz in s0:

Pete>     asm volatile("fsetc.s0 0x7f, 0x01");

Pete> Or dup s0 into s2:

Pete>     asm volatile("fsetc.s2 0x7f, 0x00");

Pete> Not sure if/why intel gave us this instruction.  Perhaps
Pete> switching speed is important to some apps.

Hmmm need to go read manuals when I get back from Atlanta.

Thanks
Jes

