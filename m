From: Matthew Wilcox <matthew@wil.cx>
Date: Mon, 28 Nov 2005 16:27:20 +0000
Subject: Re: initrd_size inflation breaks initramfs
Message-Id: <20051128162720.GC13338@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1133159027.6062.98.camel@localhost>
In-Reply-To: <1133159027.6062.98.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Nov 28, 2005 at 09:24:33AM -0700, dann frazier wrote:
> I'm seeing this with Debian's 3.4-9 - 3.4 appears to be the latest
> release here:
>   ftp://ftp.hpl.hp.com/pub/linux-ia64/
> 
> But it appears to be > 2 years old.

Upstream moved:

http://elilo.sourceforge.net/cgi-bin/blosxom

3.5-pre1 says:
 1) Support for compressed ia32 kernels.
 2) Support for subnet-specific config files.
 3) initrd handling bug fixed.

