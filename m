From: jbarnes@sgi.com (Jesse Barnes)
Date: Mon, 04 Aug 2003 22:01:39 +0000
Subject: Re: [PATCH] sn2 module (& other misc.) fixes
Message-Id: <marc-linux-ia64-106003456019700@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106003174416756@msgid-missing>
In-Reply-To: <marc-linux-ia64-106003174416756@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Aug 04, 2003 at 10:54:23PM +0100, Christoph Hellwig wrote:
> On Mon, Aug 04, 2003 at 02:14:04PM -0700, Jesse Barnes wrote:
> >  nasid_t master_baseio_nasid = INVALID_NASID;	/* This is the master base I/O nasid */
> > +EXPORT_SYMBOL(master_nasid);
> 
> why is this exported?

Because no one's ripped it out yet.

> >  int num_base_io_scsi_ctlr = 2; /* used by syssgi */
> >  vertex_hdl_t		base_io_scsi_ctlr_vhdl[NUM_BASE_IO_SCSI_CTLR];
> > +EXPORT_SYMBOL(base_io_scsi_ctlr_vhdl);
> 
> Why do you want this export.  Or rather why does this tasteless stuff
> exist at all?  (And the comment looks wrong, too..)

Same here.

> >  partid_t sn_partid = -1;
> > +EXPORT_SYMBOL(sn_partid);
> > +
> >  char sn_system_serial_number_string[128];
> >  u64 sn_partition_serial_number;
> > +EXPORT_SYMBOL(sn_system_serial_number_string);
> > +EXPORT_SYMBOL(sn_partition_serial_number);

Modules.

> >  short physical_node_map[MAX_PHYSNODE_ID];
> > +EXPORT_SYMBOL(physical_node_map);
> 
> Again, what is all this for?

Modules.

Jesse
