From: Dean Nelson <dcn@sgi.com>
Date: Thu, 05 May 2005 12:44:28 +0000
Subject: Re: catching up on the backlog
Message-Id: <20050505124428.GA13504@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200505032108.j43L8wc21277@unix-os.sc.intel.com>
In-Reply-To: <200505032108.j43L8wc21277@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, May 04, 2005 at 01:59:20PM -0700, Luck, Tony wrote:
> >Ok, I've applied these locally.  I can't connect to kernel.org at the
> >moment (I think the machine I need is being upgraded at the 
> >moment). I'll push them up as soon as I can.
> 
> Ok. These are now up on kernel.org.

I again cg-clone'd your release tree and now that the two previously missing
patches are in it, everything (with 'CONFIG_IA64_SGI_SN_XP=m' configured)
builds cleanly, boots and runs on a SGI Altix.

Thanks.
