From: Randolph Chung <randolph@tausq.org>
Date: Wed, 14 Nov 2001 18:26:44 +0000
Subject: Re: [Linux-ia64] ia-64 cast warning??
Message-Id: <marc-linux-ia64-105590698805514@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805513@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805513@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

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

circbuff is an unsigned short *, you are casting it to an unsigned int.
Cast it to unsigned long or uintptr_t instead.

randolph
-- 
   @..@                                         http://www.TauSq.org/
  (----)
 ( >__< )
 ^^ ~~ ^^

