From: Rajesh Shah <rajesh.shah@intel.com>
Date: Thu, 20 Jan 2005 02:38:53 +0000
Subject: Re: [Pcihpd-discuss] [PATCH] Convert acpiphp to use generic resource code
Message-Id: <20050119183853.C12618@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jan 19, 2005 at 06:51:20PM +0000, Matthew Wilcox wrote:
> 
> This patch converts acpiphp to use the generic PCI resource assignment
> code.  It's quite large, but most of it is deleting the acpiphp_pci and
> acpiphp_res files.  It's tested on an hp Integrity rx8620 (which won't
> work without this patch).  Testers with other hardware welcomed.
> 
I've been playing around in this area too, working on root bridge
hot-plug. I like these changes very much, and will move my patches
on top of yours.

One nit - this patch does not program hpp values into hotplugged
devices. This is easy to fix, since you already have the values
as part of the bridge structure.

Rajesh
