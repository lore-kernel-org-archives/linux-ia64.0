From: Andrew Morton <akpm@osdl.org>
Date: Sat, 07 Feb 2004 05:49:47 +0000
Subject: Re: gcc problems
Message-Id: <20040206214947.686e6bbf.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040206000058.7e928d80.akpm@osdl.org>
In-Reply-To: <20040206000058.7e928d80.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jim Wilson <wilson@specifixinc.com> wrote:
>
> On Fri, 2004-02-06 at 09:34, Wichmann, Mats D wrote:
>  > If it's a question of glibc 2.2.x vs. 2.3.x, there are
>  > ia64 Linux distributions based on glibc 2.2 that work
>  > pretty well - SUSE's SLES8, for example.
> 
>  gcc-3.x will have some problems when used on a glibc-2.2.x system, but
>  most of them are obscure, and probably none of them apply to building
>  kernels, because the kernel doesn't link in glibc.
> 
>  It is reasonable that gcc should be buildable though.  I believe the
>  following patch solves this problem.  I just ifdefed out the code for
>  old glibc versions.  I see no point in trying to make this work, because
>  unwinding will fail (for user apps) for other reasons if you are using
>  glibc-2.2.4.
> 
>  I don't have access to a glibc-2.2.4 system for testing.  I can't use
>  such old systems for gcc 3.x development.  It works OK for glibc 2.3,
>  where it has no effect.  If someone tells me that this does work, then I
>  can check it into the FSF gcc sources.
> 
>  2004-02-06  James E Wilson  <wilson@specifixinc.com>
> 
>  	* config/ia64/linux.h (MD_FALLBACK_FRAME_STATE_FOR): Only define for
>  	glibc 2.3 or better.

This gave me a successful build of

	gcc (GCC) 3.5.0 20040206 (experimental)

on

	linux-tiger:/usr/src/gcc-cvs-obj> cat /etc/issue
	Red Hat Linux Advanced Server release 2.1AS (Derry)

	linux-tiger:/usr/src/gcc-cvs-obj> rpm -q glibc
	glibc-2.2.4-32.3

Thanks.	  Ship it.
