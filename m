From: Simon Horman <horms@verge.net.au>
Date: Tue, 08 May 2007 07:23:25 +0000
Subject: Re: kexec/kdump: Use generic elf code on ia64
Message-Id: <20070508072323.GB31881@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070425090903.GA26412@verge.net.au>
	<20070508063239.GA31881@verge.net.au>
	<1178607344.2613.9.camel@linux-znh>
In-Reply-To: <1178607344.2613.9.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zou Nan hai <nanhai.zou@intel.com>
Cc: kexec@lists.infradead.org, Linux-IA64 <linux-ia64@vger.kernel.org>, Vivek Goyal <vgoyal@in.ibm.com>, fastboot <fastboot@lists.osdl.org>, "Luck,
	Tony" <tony.luck@intel.com>

On Tue, May 08, 2007 at 02:55:44PM +0800, Zou Nan hai wrote:
> Hi, 
> 	The patch looks ok to me.  
> However split the patch in 2 parts, 
> 1. Put pr_status to percpu data to save stack usage.
> 2. IA64 specific part.
>    may help others to review the patches.

Sure, will do.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

