From: Dan Pop <Dan.Pop@cern.ch>
Date: Wed, 14 Nov 2001 19:03:08 +0000
Subject: Re: [Linux-ia64] ia-64 cast warning??
Message-Id: <marc-linux-ia64-105590698805516@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805513@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805513@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Wed, 14 Nov 2001, Pereira, D LailaX E wrote:

> Consider the following macro : executing in a program , on linux ia-64
> machine: 
> ifdef CIRC_DEBUG
> #define CBUFSIZE 32768 
> #define CHECK_CIRC_ALIGNMENT( A ) \
> if (((unsigned int)(circbuff + A))%sizeof(caddr_t)) { A += (sizeof(caddr_t)
> - (((unsigned int)(circbuff + A))%sizeof(caddr_t)))/sizeof(unsigned short);
> }
> 
> #define CIRCADDR( A ) \
> CHECK_CIRC_ALIGNMENT(CBptr) \
> *(caddr_t *)(circbuff + CBptr) = A; \
> CBptr = (CBptr + sizeof(caddr_t)/sizeof(short)) % CBUFSIZE;
> 
> #endif
> 
> 
> int main(){
>   unsigned int volatile* mask;
>   unsigned short circbuff[CBUFSIZE];
>   unsigned int CBptr;
>   unsigned int current;
> .....
>   CHECK_CIRC_ALIGNMENT(current);
> .....
> }
> 
> I always get the warning : 
> warning : cast from pointer to integer of different size  on the line
> CHECK_CIRC_ALIGNMENT(current);
> 
> when I compile the above program.I want to get rid of the warning.I am not
> able to figure out why I get this warning.??

The reason of the warning is OBVIOUS: you are converting a pointer
value (circbuff + current), which is a 64-bit value, to unsigned int,
which is a 32-bit type.  The compiler is warning you that you may lose
significant bits in this conversion, and this is the case, indeed, on
Linux-ia64.

As you have already been told, if you need to make such conversions,
use the type uintptr_t, defined in <stdint.h>, instead of some
arbitrary, hard coded integer type.

Dan 


