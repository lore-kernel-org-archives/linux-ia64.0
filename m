From: Matthew Wilcox <willy@debian.org>
Date: Fri, 15 Nov 2002 14:17:55 +0000
Subject: Re: [Linux-ia64] Re: memcpy failure
Message-Id: <marc-linux-ia64-105590709805452@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805424@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805424@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Nov 15, 2002 at 02:51:36PM +0100, Christian Cotte-Barrot wrote:
> Matthew Wilcox wrote:
> > _what_ bad return from memcpy?!  memcpy returns the pointer that was
> > passed to it.  What are you going to check for?
> > 
> 
> Simply, bad return is whatever is not equal to the dest pointer:
>   if ((memcpy(rptr, ch->rxptr + tail, dataToRead)) != rptr)
>     ...

No.  You don't get it.  memcpy returns the pointer that was passed in.
Nothing more, nothing less.  There is no `error return'.  There is no
`what if'.  memcpy is defined to succeed.  Look:

"
7.21.2.1 The memcpy function

Synopsis
#include <string.h>
void *memcpy(void * restrict s1, const void * restrict s2, size_t n);

Description
The memcpy function copies n characters from the object pointed to by s2
into the object pointed to by s1. If copying takes place between objects
that overlap, the behavior is undefined.

Returns
The memcpy function returns the value of s1.
"

Testing the result of memcpy is bad C.  Don't ever do it.

-- 
Revolutions do not require corporate support.

