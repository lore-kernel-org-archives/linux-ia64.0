From: dann frazier <dannf@hp.com>
Date: Thu, 22 Sep 2005 22:04:59 +0000
Subject: RE: ip_contrack refuses to load if built UP as a module on IA64
Message-Id: <1127426700.25159.63.camel@krebs.dannf>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F0443A5FA@scsmsx401.amr.corp.intel.com>
	 <ed5aea430508301229386fc596@mail.gmail.com>
	 <17172.54563.329758.846131@wombat.chubb.wattle.id.au>
	 <17174.35525.283392.703723@berry.gelato.unsw.EDU.AU>
In-Reply-To: <17174.35525.283392.703723@berry.gelato.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Chubb <peterc@gelato.unsw.edu.au>
Cc: linux-ia64@vger.kernel.org, tony.luck@intel.com, dmosberger@gmail.com, linux-kernel@vger.kernel.org

On Thu, 2005-09-01 at 14:59 +1000, Peter Chubb wrote:
> 
> This patch makes UP and SMP do the same thing as far as module per-cpu
> data go.
> 
> Unfortunately it affects core code.

It causes 2.6.13/x86 to fail to link:
kernel/built-in.o: In function `load_module':
: undefined reference to `percpu_modcopy'
make: *** [.tmp_vmlinux1] Error 1

fyi, this is a problem we're seeing in the Debian UP packages:
  http://bugs.debian.org/cgi-bin/bugreport.cgi?bug25070

