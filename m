From: Jeff Woods <kazrak+kernel@cesmail.net>
Date: Wed, 24 Dec 2003 23:44:15 +0000
Subject: Re: segv at strcmp
Message-Id: <marc-linux-ia64-107230959611195@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107230762310061@msgid-missing>
In-Reply-To: <marc-linux-ia64-107230762310061@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

At 12/24/2003 03:13 PM -0800, umut aymakoglu wrote:
>The segv happens at memcmp() at a line like: 'strcmp(x, "this is 24 chars 
>long")' where x is a char pointer with a length of 7 and the constant has 
>a length of 24. x is located at the first 8 bytes of the last 16 bytes at 
>the end of a non-contiguous shared memory segment. memcmp() segvs when it 
>tries to load 8 bytes from the "r19" register which initially has the 
>address of x and points to the end of the segment when the segv happens.

So are you calling strcmp() or memcmp() ?  If you are calling strcmp(), it 
sounds like the "last 16 bytes" are not null-terminated to be a valid 
string and the strcmp() is running off the end of the memory segment which 
causes it to try address memory to which it doesn't have access.  If you're 
calling memcmp() with a length longer than 16 then it is also running off 
the end of the segment.

--
Jeff Woods <kazrak+kernel@cesmail.net> 


