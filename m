From: KOCHI Takayoshi <t-kouchi@mvf.biglobe.ne.jp>
Date: Wed, 15 Aug 2001 22:29:19 +0000
Subject: Re: [Linux-ia64] rwlock and atomic_sub on ia64
Message-Id: <marc-linux-ia64-105590698805084@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805063@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805063@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 15 Aug 2001 15:30:17 -0500
Noah Romer <nromer@lsil.com> wrote:

> On another note, I'm still a little puzzled by the warnings I got when 
> using atomic_sub. I was passing a u8 value in as the amount to be 
> subtracted, and got four
> 
>     mptlan.c:1135: warning: comparison is always false due to limited 
> range of data type
> 
> Now, I can make the warning go away by changing the variable to an int 
> (but not by casting the u8 to an int), but it seems odd that gcc would 
> complain about the size of a u8 variable making the comparison always 
> false. I started poking around in the output for other drivers, and 
> found the above warning for all sorts of code (a lot of it involving bh 
> data types). This is probably a question for the gcc folks, but . . . ;)

This is because atomic_sub is actually a macro defined in
asm-ia64/atomic.h and it compares value against negative values
to get optimized code.

So, four comparison against negative numbers makes four warnings
for the single atomic_sub.

Here is the quote of atomic_sub

#define atomic_sub_return(i,v)						\
	((__builtin_constant_p(i) &&					\
	  (    ( i =  1) || ( i =  4) || ( i =  8) || ( i = 16)	\
	    || ( i = -1) || ( i = -4) || ( i = -8) || ( i = -16)))	\
	 ? ia64_fetch_and_add(-(i), &(v)->counter)			\
	 : ia64_atomic_sub(i, v))

#define atomic_sub(i,v)		atomic_sub_return((i), (v))

-- 
KOCHI Takayoshi <t-kouchi@cq.jp.nec.com/t-kouchi@mvf.biglobe.ne.jp>


