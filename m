From: Zack Weinberg <zack@codesourcery.com>
Date: Tue, 09 Mar 2004 20:51:05 +0000
Subject: Re: Possible race condition with deferred binding on IPF
Message-Id: <87ad2pzqva.fsf@egil.codesourcery.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <BEC72735-6E38-11D8-9E11-003065589C02@cup.hp.com>
In-Reply-To: <BEC72735-6E38-11D8-9E11-003065589C02@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jim Wilson <wilson@specifixinc.com> writes:

> On Mon, 2004-03-08 at 10:08, Zack Weinberg wrote:
>>         addl    r2 = @gprel(plt_reserve+8), r2 ;;
>>         ld8     r17 = [r2], 8
>>         mov     b6 = r17
>>         ld8     r1 = [r2], -16
>>         ld8     r16 = [r2]
>>         br      b6 ;;
>
> You are missing a stop bit between the load of r17 and its use.
>
> You have two post-increment addressing uses of r2.  A post-increment
> address is both a read and a write of the register.  Thus you need stop
> bits between the first and second loads to avoid a read-after write
> dependency violation.  Likewise, between the second and third loads.
>
> So your example needs 4 stop bits total (5 instruction groups).  The ABI
> recommended sequence only requires 2 (3 instruction groups).

Yeah, I was afraid of that.  I haven't had much luck making sense of
the stop-bit rules.

zw
