From: Dan Pop <Dan.Pop@cern.ch>
Date: Mon, 12 Nov 2001 23:50:37 +0000
Subject: RE: [Linux-ia64] Unaligned access in ia64
Message-Id: <marc-linux-ia64-105590698805478@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805472@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805472@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Mon, 12 Nov 2001, Pereira, D LailaX E wrote:

> My program still does not port properly gives the "unaligned access
> warnings" while running. Also, When I make the files, I also get the
> warnings of the following type::
> warning: cast from pointer to integer of different size
> This happens when I convert (void*) pointer to int i. 

You shouldn't do that, because this conversion is likely to result in
loss of information, since pointers are 64-bit on IA-64 Linux.

> The following warning is also displayed: 
> cast to pointer from integer of different size 
> 
> This happens when I convert int i to (void*) pointer . 
> for example::  function((void*)i);

This should not cause any problems, but I can't see its usefulness.

> How can these warnings be avoided? 

If you want to mix pointers and integers in this way, use long's
instead of int's.

Also, double check that all the functions returning pointers that your
program calls are properly declared, either explicitly or by the
inclusion of the appropriate headers. 

Dan


