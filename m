From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Wed, 05 Feb 2003 01:46:37 +0000
Subject: Re: [Linux-ia64] _raw_write_trylock() missing
Message-Id: <marc-linux-ia64-105590709805814@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805809@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805809@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Feb 04, 2003 at 03:18:22PM +0100, Joel GUILLET wrote:
> What the macro is doing : (at least, what I think it is doing)
> 
> - if the actual lock value is equal to "0",
> 	change the lock value to "00.....0001"
> 	else do nothing
> 
> The code for this : (in include/asm-ia64/spinlock.h)
> 		"dep r29 = -1, r0, 31, 1\n"			

doesn't this make the value of r29 0x80000000?  i.e the 1 is at the
wrong end.

> 		"cmpxchg4.acq result = [rw], r29, ar.ccv\n"		      

so here you end up swapping 0x8000000 into rw if rw=0

i think maybe just making doing mov r29 = 1 above will do what you
want.  

-i
ianw@gelato.unsw.edu.au
http://www.gelato.unsw.edu.au

