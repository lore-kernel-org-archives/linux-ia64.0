From: m.delahaye@esiee.fr (Matthieu Delahaye)
Date: Wed, 26 Mar 2003 10:07:46 +0000
Subject: Re: [parisc-linux] Re: [Linux-ia64] Linux, Itanium and PA/RISC
Message-Id: <marc-linux-ia64-105590723705314@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Mar 24, 2003 at 11:19:08AM -0800, David Mosberger wrote:
> >>>>> On Mon, 24 Mar 2003 12:10:37 +0000, Matthew Wilcox <willy@debian.org> said:
> 
>   Matthew> On Mon, Mar 24, 2003 at 11:41:18AM +0100, Adriano Galano
>   Matthew> wrote:
>   >> Hi all:
> 
>   >> I read that IA-64 support PA-RISC instruction mapping. That's
>   >> mean that I can use Linux for PA/RISC
>   >> (http://www.parisc-linux.org/) in a Itanium 2 computer?
> 
>   Matthew> No.  You certainly can't run a PA-RISC kernel on an IA64
>   Matthew> box, just like you can't run an x86 kernel on an ia64 box.
> 
> Ugh, that's not strictly true.  You definitely can boot x86 linux and
> windows 98 on Itanium.  I believe the same is true for Itanium 2 if
> you have Intel's firmware, though I have never tried that myself.

...And perhaps you don't forget to add support for the chipset in the
x86/hppa kernel. 

Is the Intel's firmware freely distributed or it is
internal only?

Matthieu


