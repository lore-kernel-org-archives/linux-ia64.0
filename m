From: "Pereira, D LailaX E" <d.lailax.e.pereira@intel.com>
Date: Mon, 12 Nov 2001 16:56:10 +0000
Subject: RE: [Linux-ia64] Unaligned access in ia64
Message-Id: <marc-linux-ia64-105590698805474@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805472@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805472@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi 
My program still does not port properly gives the "unaligned access
warnings" while running. Also, When I make the files, I also get the
warnings of the following type::
warning: cast from pointer to integer of different size
This happens when I convert (void*) pointer to int i. 

The following warning is also displayed: 
cast to pointer from integer of different size 

This happens when I convert int i to (void*) pointer . 
for example::  function((void*)i);

How can these warnings be avoided? 

d'laila 

-----Original Message-----
From: n0ano@indstorage.com [mailto:n0ano@indstorage.com]
Sent: Monday, November 12, 2001 10:38 AM
To: Pereira, D LailaX E
Cc: 'linux-ia64@linuxia64.org'
Subject: Re: [Linux-ia64] Unaligned access in ia64


D'Laila-

I should first point out that those were warnings, not errors.  Your
program should have executed properly, all be it a lot slower that if
it didn't do the unaligned accesses.

The simple answer is that all accesses should be to natively aligned
boundaries.  That means 2-byte shorts should be on 2-byte boundaries,
4-byte ints should be on 4-byte boundaries and so on.

Also, you should note that you are probably paying a performance
penality on your Intelx86 machine also, you just don't know about
it because the CPU doesn't even tell you when you make an unaligned
access.

On Mon, Nov 12, 2001 at 08:24:38AM -0800, Pereira, D LailaX E wrote:
> Hi 
> I have an application running fine on the Intelx86 machines. When I run
the
> same on itanium machine ( linux OS) , I get the following  errors:
> stress.udp(16868):unaligned access  to 0x4000000000003541,
> ip=0x400000000001cfe0
> stress.udp(16868):unaligned access  to 0x4000000000003541,
> ip=0x400000000001c551
> 
> What could be the possible causes for this? Can anyone please point out?
> what are the general cautions to be taken while porting applications to
> itanium? for eg any pointer conversions , int conversions etc 
> 
> thanks
> d'laila 
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@indstorage.com
Ph: 303/652-0870x117

