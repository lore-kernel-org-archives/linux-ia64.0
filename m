From: Paul Jackson <pj@sgi.com>
Date: Mon, 03 May 2004 22:10:44 +0000
Subject: Re: arch/ia64/ia32/binfmt_elf32.c: elf32_map() broken ia64 build
Message-Id: <20040503151044.087d79ca.pj@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040426185633.7969ca0d.pj@sgi.com>
	<20040501013304.32a750d3.pj@sgi.com>
	<4096526C.4060503@BitWagon.com>
	<20040503140459.10b9d3eb.pj@sgi.com>
	<1083619742.24587.3.camel@linux.littlegreen>
In-Reply-To: <1083619742.24587.3.camel@linux.littlegreen>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Hearn <mh@codeweavers.com>
Cc: jreiser@BitWagon.com, akpm@osdl.org, pageexec@freemail.hu, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, ashok.raj@intel.com

> It would be nice to get the bssprot patch in though, ...

Once you've digested Andrew's query as to whether there is a simpler way
to do this, and know whether it's this patch or some other that you want
to push, then if you send me a patch, ideally including the printk's in
fs/binfmt_elf.c that Reiser thought might facilitate debugging, then I'd
be willing to apply the patch and try booting it on my ia64 SN2 hardware.

-- 
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373
