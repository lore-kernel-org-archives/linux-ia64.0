From: "Van Maren, Kevin" <kevin.vanmaren@unisys.com>
Date: Fri, 31 May 2002 14:29:05 +0000
Subject: RE: [Linux-ia64] Building native 32 bit binaries
Message-Id: <marc-linux-ia64-105590701905628@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905624@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905624@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

No, Linux does not support 32-bit IA64 binaries.

You could install a cross-compiler and build 32-bit IA32 binaries, and run
those;
or, you can build 64-bit IA64 binaries.

Kevin

> -----Original Message-----
> From: knightgun@email.si [mailto:knightgun@email.si]
> Sent: Friday, May 31, 2002 4:25 AM
> To: linux-ia64@linuxia64.org
> Subject: [Linux-ia64] Building native 32 bit binaries
> 
> 
> Hello,
> 
> i have a question regarding 32 bit binaries on IA-64 linux.
> I am using RedHat 7.1 with gcc 2.96 and kernel 2.4.3-12smp.
> 
> I have build 32bit binaries on an x86 system and these work 
> just fine however I 
> need to build IA-64 native 32bit binaries. Is this possible and how ?
> 
> Thank you in advance,
> 
> Gregor

