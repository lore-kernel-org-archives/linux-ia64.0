From: Michael Madore <mmadore@turbolinux.com>
Date: Mon, 31 Jul 2000 23:14:36 +0000
Subject: Re: [Linux-ia64] integer -> pointer question
Message-Id: <marc-linux-ia64-105590678205253@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205250@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205250@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Hi Michael
> 
> Storing integers in void pointers without a cast is simply broken and
> nobody should do that or to be more precise you cannot expect void *
> to be the same size as int.
> 
> Basically the correct solution is to LART the programmer of the bad
> code.
> 
> Jes

The code does perform the cast, but since the upper four bytes of the
pointer will be meaningless, it's spits out a warning.

Mike 



