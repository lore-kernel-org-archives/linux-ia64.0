From: Dan Kegel <dank@kegel.com>
Date: Wed, 11 Feb 2004 05:59:58 +0000
Subject: Re: offsets.h and 32 -> 64 bit cross-compiling
Message-Id: <4029C4DE.2070107@kegel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <401DA58C.8070105@kegel.com>
In-Reply-To: <401DA58C.8070105@kegel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:
>>>>>>On Sun, 01 Feb 2004 17:19:08 -0800, Dan Kegel <dank@kegel.com> said:
> 
> 
>   Dan> Sadly, that fix seems to be insufficient.
> 
>   Dan> On my x86 build machine, 'make ARCH=ia64 dep' for linux-2.4.21 now fails with errors like
> 
>   Dan> gcc -g -O2 -Wall -D__KERNEL__ -I/cross/linux-2.4.21/include -DKBUILD_BASENAME= print_offsets.c -o print_offsets
> 
> Umh, you're using the wrong compiler.  You must use the IA-64
> cross-compiler for print_offsets.c.  That's the entire point of
> generating offsets.h at build-time: to ensure the definitions match
> your (IA-64) compiler (and kernel-configuration).
> 
> When cross-compiling, you must set CROSS_COMPILE to the path that
> contains the cross-tools.  When you do that, print_offsets.c will only
> be translated to print_offsets.s and then converted to offsets.h via a
> small awk-script.  Something like:
> 
> 	make CROSS_COMPILE=/opt/ia64-cross-compiler/bin/
> 
> should do (with the correct path of course...).

But how do I do that when I'm building the cross-compiler?
As far as I can tell, it looks like offsets.h is needed to
compile the cross-compiler.  Perhaps I can compile the bootstrap
compiler with a dummy version of offsets.h?

Have you ever tried to build a cross-compiler for ia64 from
virgin gnu tarballs without referring to any installed tools?
That's what I am trying to do with http://kegel.com/crosstool
Works great for most architectures, and it used to work fine for
ia64, but it broke when y'all took offsets.h out of the kernel source
tree, I think.
- Dan


-- 
US citizens: if you're considering voting for Bush, look at these first:
http://www.misleader.org/
http://www.cbc.ca/news/background/arar/
http://www.house.gov/reform/min/politicsandscience/
