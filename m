From: Rahul Chaturvedi <justanotheraliasforrahul@yahoo.com>
Date: Wed, 14 Apr 2004 05:34:32 +0000
Subject: RE: Questions on the stack for IA64
Message-Id: <20040414053432.2971.qmail@web61206.mail.yahoo.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040413051722.84368.qmail@web61202.mail.yahoo.com>
In-Reply-To: <20040413051722.84368.qmail@web61202.mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>   Rahul> Does the compiler ever touch this backing
> store?
> 
> Not directly.

Another question on this, who allocates the memory for
the backing store? What if the RSE runs out of memory
there?

> 
>   Rahul> I believe it is used during a stack unwind?
> 
> Yes (as is the memory stack and the registers).
> 
>   Rahul>         printf("", a, b, c, d, e, f, g, h,
> i, j, k, l, m, n,
>   Rahul> o, p, q, r, s, t, u, v, w, x, y, z, aa, bb,
> cc, dd, ee, ff,
>   Rahul> gg);
> 
>   Rahul> As you can see, almost all the parameters
> are being "st4'd"
>   Rahul> to memory. From the architecture
> specification, shouldn't all
>   Rahul> these be moved into registers? I have a
> total of much lesser
>   Rahul> than 96 parameters?
> 
> You need to look at the software conventions &
> runtime architecture guide:
> 
>  
>
http://www.intel.com/design/itanium/downloads/245358.htm
> 
> It specifies that up to 8 registers are used for
> argument passing.
> 

Oh okay. I'll read the rest of the guide before I ask
more stupid questions on this :)


> There are also some fine books that might help you
> get started. ;-)

Books are expensive (especially in India) :( Processor
manuals and mailing lists are free :)



	
		
__________________________________
Do you Yahoo!?
Yahoo! Tax Center - File online by April 15th
http://taxes.yahoo.com/filing.html
