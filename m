From: Keith Owens <kaos@sgi.com>
Date: Wed, 11 Feb 2004 06:17:53 +0000
Subject: Re: offsets.h and 32 -> 64 bit cross-compiling
Message-Id: <6299.1076480273@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <401DA58C.8070105@kegel.com>
In-Reply-To: <401DA58C.8070105@kegel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 10 Feb 2004 21:59:58 -0800, 
Dan Kegel <dank@kegel.com> wrote:
>David Mosberger wrote:
>> Umh, you're using the wrong compiler.  You must use the IA-64
>> cross-compiler for print_offsets.c.  That's the entire point of
>> generating offsets.h at build-time: to ensure the definitions match
>> your (IA-64) compiler (and kernel-configuration).
>
>But how do I do that when I'm building the cross-compiler?
>As far as I can tell, it looks like offsets.h is needed to
>compile the cross-compiler.  Perhaps I can compile the bootstrap
>compiler with a dummy version of offsets.h?

Which compiler file needs asm/offsets.h?  I doubt that any user space
code should be using that file, it is probably being included by
mistake.

QAD workaround, copy /usr/include/asm/offsets.h from an ia64 system to
/usr/include/asm.

