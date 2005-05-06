From: Grant Grundler <iod00d@hp.com>
Date: Fri, 06 May 2005 15:56:20 +0000
Subject: Re: mem_map
Message-Id: <20050506155620.GA23553@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <851caabb05050607291364149a@mail.gmail.com>
In-Reply-To: <851caabb05050607291364149a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, May 06, 2005 at 07:59:59PM +0530, Vaibhav Sharma wrote:
> hi all,
> Can any body provide any information for the significance of
> "CONFIG_VIRTUAL_MEM_MAP"?

	help
	  Say Y to compile the kernel with support for a virtual mem map.
	  This code also only takes effect if a memory hole of greater than
	  1 Gb is found during boot.  You must turn this option on if you
	  require the DISCONTIGMEM option for your machine. If you are
	  unsure, say Y.

The first sentence could define what a virtual mem map is.
IIRC, it's something to do with non-contiguous page table.

grant
