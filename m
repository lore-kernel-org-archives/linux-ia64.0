From: Cary Coutant <cary@cup.hp.com>
Date: Tue, 17 Oct 2000 22:53:01 +0000
Subject: Re: [Linux-ia64] avoiding float underflow software assist
Message-Id: <marc-linux-ia64-105590678205586@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205556@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205556@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>This is definitely your best approach to setting the ftz bit:
>
>    fsetc.s0 0x7f,0x01
>    fsetc.s2 0,0x40
>    fsetc.s3 0,0x40

Oops -- those last two instructions should have 0x7f as the first 
operand. Sorry!


