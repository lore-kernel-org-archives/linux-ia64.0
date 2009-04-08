From: Robin Holt <holt@sgi.com>
Date: Wed, 08 Apr 2009 01:03:31 +0000
Subject: Re: cross-compilers
Message-Id: <20090408010331.GB10768@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090408003921.GA5054@ldl.fc.hp.com>
In-Reply-To: <20090408003921.GA5054@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Chiang <achiang@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

Don't know if this answers your problem, but I use the tools from
emdebian and they do not suffer from the problems you list below.

Good Luck,
Robin

On Tue, Apr 07, 2009 at 06:39:21PM -0600, Alex Chiang wrote:
> Hi Andrew,
> 
> I've been using your cross-compilers here:
> 
> 	http://userweb.kernel.org/~akpm/cross-compilers/
> 
> for a long time now, but they're starting to suffer from a bit of
> neglect.
> 
> For example, the ia64 bundle, which used gcc 3.4.5 is now finally
> too old to build 2.6.30-rc1, because of a gcc bug related to
> labels.
> 
> Some of the newer bundles which use gcc 4.1.0 don't work because
> of a check in:
> 
> 	include/linux/compiler-gcc4.h
> 
> So my question is, do you still use those tools hosted on
> kernel.org or do you have a new solution these days?
> 
> If you have a new solution, I'd like to hear it, because I found
> those cross-compilers pretty useful, as I'm sure others did.
> 
> I spent most of yesterday fiddling about and managed to build an
> x86_64 host, ia64 target, gcc 4.2.3, glibc 2.3.6 bundle, and it
> all seems to work.
> 
> Is this something you're interested in? I could send you my
> tarball (and slowly work on some of the other archs).
> 
> If so, what were the crosstool build options you used? I'm
> specifically wondering about:
> 
> 	- should I am for lowest common denominator host or are
> 	  you ok with x86_64 host
> 	
> 	- did you statically link the toolchain? or is it
> 	  dynamically linked?
> 
> Thanks.
> 
> /ac
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
