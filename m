From: n0ano@indstorage.com
Date: Mon, 12 Nov 2001 15:14:33 +0000
Subject: Re: [Linux-ia64] Can i run 32-bit executale on IA-64 (HP)
Message-Id: <marc-linux-ia64-105590698805469@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805468@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805468@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ramesh-

1)  IA64 Linux definitely supports IA32 programs.  In fact, if you
know of an IA32 Linux program that doesn't work on IA64 let met
know and I'll fix it.

2)  Although the CPU can conceptually supports 32 bit and 64 bit
IA64 code this would raise a lot of problems and no one has
raised a compelling reason for supporting it.  Therefore, no,
the current version of IA64 Linux doesn't support 32-bit IA64
applications and there are not plans to support this.

On Mon, Nov 12, 2001 at 04:08:28PM +0530, Ramesh Kumar Verapaneni wrote:
> Hi,
> 
> Does IA-64 Linux  (HP) supports the  coexistence of 32 bit- 64 bit
> application.
>  Does  IA -64 Linux (HP) gives 32 bit libs also.
> 
> -reg
> ramesh
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

