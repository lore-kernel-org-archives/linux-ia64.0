From: Cary Coutant <cary@cup.hp.com>
Date: Wed, 21 Mar 2001 23:42:50 +0000
Subject: Re: [Linux-ia64] Unwind problem for __attribute__ noreturn
Message-Id: <marc-linux-ia64-105590693005330@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>In the case of a call to a "noreturn" procedure, I'll offer the opinion 
>>that having the unwinder decrement the rp is not correct.
>
>Why?  It isn't good enough to say that this is wrong.  You should justify
>why you think it is wrong.

OK. The problem is that rp doesn't tell us where the branch is: even 
excluding examples like Keith's, you don't know whether to back up one, 
two, or three instruction slots. If you allow for the short-circuit 
return, you're totally lost. The only reasonable assumption the unwinder 
can make is that rp, being where control would normally resume in that 
frame, is the address that determines the unwind state.

-cary

