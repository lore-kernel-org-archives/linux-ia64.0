From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 05 Dec 2001 21:15:50 +0000
Subject: [Linux-ia64] Re: alpha bug in signal handling
Message-Id: <marc-linux-ia64-105590698805627@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805617@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805617@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>
>I think David (Mosberger, not Miller :) is right here, and in fact
>this is also wrong on PPC at the moment.  However, the worst case is
>that the reschedule or signal delivery will get delayed until the next
>interrupt on that cpu (max 1/HZ seconds).  Since it is a pretty narrow
>window for the race I think it would be hard to observe the effect of
>the bug.

Yup, I found that some time ago. I though I even fixed it while hacking
on the return from exception path. The fix has probably been lost along
with some of that experimental stuff I was doing at that time though,
I remember you saying the problem wasn't that big.

Ben.



