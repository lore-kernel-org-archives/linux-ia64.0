From: Jun Nakajima <jun@sco.com>
Date: Mon, 13 Nov 2000 22:10:44 +0000
Subject: Re: [Linux-ia64] Recommended compiler for compiling kernels test1 0 and
Message-Id: <marc-linux-ia64-105590678205702@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205680@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205680@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Yes, I'm running 2.4 kernels (test10, for example) on IA-32 machines as
well, switching kernels on Redhat 7.0 based systems. They have been
compiled by the gcc 2.95.

Jim Wilson wrote:
> 
> >The new one is gcc 2.95 and it is terrible for compiling kernels. ( ia32 )
> 
> To be more precise, it is terrible for compiling old (2.2 based) linux kernels,
> because these old linux kernels don't have any of the bug fixes needed to work
> with new gcc releases.  It should be fine for compiling 2.4 based kernels.
> In fact, nearly everybody uses a gcc-2.95 based compiler for their ia64 kernel
> compiles.
> 
> Jim
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Jun U Nakajima
Core OS Development
SCO/Murray Hill, NJ
Email: jun@sco.com, Phone: 908-790-2352 Fax: 908-790-2426

