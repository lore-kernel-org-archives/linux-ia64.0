From: Mike Hearn <mh@codeweavers.com>
Date: Mon, 03 May 2004 21:29:03 +0000
Subject: Re: arch/ia64/ia32/binfmt_elf32.c: elf32_map() broken ia64 build
Message-Id: <1083619742.24587.3.camel@linux.littlegreen>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040426185633.7969ca0d.pj@sgi.com>
	 <20040501013304.32a750d3.pj@sgi.com> <4096526C.4060503@BitWagon.com>
	 <20040503140459.10b9d3eb.pj@sgi.com>
In-Reply-To: <20040503140459.10b9d3eb.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Paul Jackson <pj@sgi.com>
Cc: John Reiser <jreiser@BitWagon.com>, akpm@osdl.org, pageexec@freemail.hu, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, ashok.raj@intel.com

On Mon, 2004-05-03 at 14:04 -0700, Paul Jackson wrote:
> Since I see Andrew dropped the patch for the moment, I'm thinking that
> the ball is back in you guys court.  

We've been able to develop a (complex) workaround for the VM layout
problems in userspace by inserting a shim between the dynamic linker and
the kernel. It sets up the address space correctly before the linker
runs so, for now, Wine will be alright without the patch - assuming we
can get the shim merged with Wine CVS of course :)

It would be nice to get the bssprot patch in though, if only because a
GNU linker script would be about 100x smaller and less scary than the
shim code.

thanks -mike

-- 
Mike Hearn <mh@codeweavers.com>
Codeweavers, Inc

