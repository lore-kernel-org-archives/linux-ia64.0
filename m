From: Richard Guenther <rguenther@suse.de>
Date: Thu, 02 Feb 2012 11:23:42 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <alpine.LNX.2.00.1202021222580.4999@zhemvz.fhfr.qr>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz> <20120202111340.GB28416@ds.suse.cz>
In-Reply-To: <20120202111340.GB28416@ds.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Sterba <dsterba@suse.cz>
Cc: Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, ptesarik@suse.cz, gcc@gcc.gnu.org

On Thu, 2 Feb 2012, David Sterba wrote:

> On Wed, Feb 01, 2012 at 04:19:18PM +0100, Jan Kara wrote:
> > We actually spotted this race in practice in btrfs on structure
> > fs/btrfs/ctree.h:struct btrfs_block_rsv where spinlock content got
> > corrupted due to update of following bitfield and there seem to be other
> > places in kernel where this could happen.
> 
> Here's the list of structures where a bitfield is shared with spinlock
> or atomic/kref within an 8B word, generated from 3.3-rc2:
> 
> spinlock+bitfield:
> 
> Struct: struct ak4113; Field: init
> Struct: struct ak4114; Field: init
> Struct: struct ak4117; Field: init
> Struct: struct btrfs_block_rsv; Field: full
> Struct: struct cm109_dev; Field: buzzer_pending
> Struct: struct pch_udc_dev; Field: active
> Struct: struct rds_iw_device; Field: dma_local_lkey
> Struct: struct sierra_intf_private; Field: suspended
> Struct: struct sm501_gpio; Field: registered
> Struct: struct unix_sock; Field: gc_candidate
> Struct: struct usb_anchor; Field: poisoned
> Struct: struct usb_wwan_intf_private; Field: suspended
> 
> atomic/kref+bitfield:
> 
> Struct: struct dlm_lock_resource; Field: migration_pending
> Struct: struct extent_map; Field: in_tree
> Struct: struct kobject; Field: state_initialized
> Struct: struct page; Field: inuse
> Struct: struct rds_ib_connection; Field: i_flowctl
> Struct: struct rds_iw_connection; Field: i_flowctl
> Struct: struct sctp_transport; Field: dead
> Struct: struct transaction_s; Field: t_synchronous_commit
> Struct: struct xfs_ioend; Field: io_isasync
> 
> 
> Not all listed structs are necessarily subject to the bug. There may be
> another mechanism preventing concurrent access to the bitfield and
> spinlock/atomic, or the bitfield is modified from a single cpu, or is
> not used. But all of them need to be reviewed of course.

To hit this bug the containing objects also have to be at least
8-byte aligned.

Richard.
