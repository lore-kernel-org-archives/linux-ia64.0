From: Nishanth Aravamudan <nacc@us.ibm.com>
Date: Fri, 22 Aug 2008 16:45:15 +0000
Subject: Re: kernel unaligned accesses on IA64 in IDE
Message-Id: <20080822164515.GA9047@us.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080819225606.GB22088@us.ibm.com> <20080820143531.GA6488@sgi.com> <20080821213146.GK11729@us.ibm.com> <20080821215426.GD8051@sgi.com> <20080822003906.GN11729@us.ibm.com> <20080822011112.GK26567@sgi.com>
In-Reply-To: <20080822011112.GK26567@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Robin Holt <holt@sgi.com>
Cc: tony.luck@intel.com, bzolnier@gmail.com, linux-ia64@vger.kernel.org, linux-ide@vger.kernel.org

On 21.08.2008 [20:11:12 -0500], Robin Holt wrote:
> Nish,
>=20
> Sounds like the callers to ide_output_data need to be doing some
> better alignment of their structures.  The thing that is confusing me
> is, I believe, my own assumption.  Do you know when this problem first
> occurred?  I have assumed it is very recent, but that does not appear
> to be the case.

Sorry about that misleading, it was unintentional. I was unable to get
serial console output on this box (well, actually, successfully boot it
in our test grid), because of CONFIG_PRINTK_TIME breakage that was
recently resolved with Tony & Peter Z.'s help.

However, I saw these "unaligned access" messages on the first successful
boot and hadn't seen them before, so I thought I should report them. I
should have been more specific that I was not sure this was a
regression, but simply didn't have data for kernels before 2.6.27-rc3. I
could go and generate that, but it seems like the IDE folks may have an
idea of what is the problem.

Sorry again,
Nish

>=20
> Thanks,
> Robin
>=20
>=20
> On Thu, Aug 21, 2008 at 05:39:06PM -0700, Nishanth Aravamudan wrote:
> > On 21.08.2008 [16:54:26 -0500], Robin Holt wrote:
> > > > [   32.597792] outsl(496, e000000644678466, 3)
> > >                             ^^^^^^^^^^^^^^^^
> > >=20
> > > This is expected to be an unsigned int * and typecast to that in outs=
l.
> > > Looks like the buffer being passed in is not properly aligned.  Time =
to
> > > go look at the caller.  Make sure buf is defined as an array of at le=
ast
> > > int size.  That should make this aligned on a 4 byte boundary instead=
 of
> > > the 2 byte boundary it is on now.
> > >=20
> > > You can cheat at finding the callers by putting
> > > 	WARN_ON(buf & 0x3);
> > > 	printk...
> >=20
> > So I tried this and it gets quite hairy quickly (I think) because what's
> > unaligned is an IDE command buffer? There is a lot of pointer passing
> > and I get lost since I don't know the IDE/elevator code very well.
> >=20
> > Here's the stack trace I'm looking at:
> >=20
> > [    5.018347]  [<a000000100015420>] show_stack+0x80/0xa0
> > [    5.018348]                                 sp=E00000130307f930 bsp=
=E0000013030793b8
> > [    5.031782]  [<a000000100015470>] dump_stack+0x30/0x60
> > [    5.031783]                                 sp=E00000130307fb00 bsp=
=E0000013030793a0
> > [    5.045223]  [<a000000100094ff0>] warn_on_slowpath+0x90/0xe0
> > [    5.045225]                                 sp=E00000130307fb00 bsp=
=E000001303079378
> > [    5.059201]  [<a000000100517480>] ide_output_data+0x3c0/0x540
> > [    5.059204]                                 sp=E00000130307fbf0 bsp=
=E000001303079310
> > [    5.073248]  [<a0000001005309e0>] cdrom_transfer_packet_command+0x2c=
0/0x340
> > [    5.073249]                                 sp=E00000130307fbf0 bsp=
=E0000013030792d0
> > [    5.088519]  [<a000000100530ac0>] cdrom_do_newpc_cont+0x60/0x80
> > [    5.088522]                                 sp=E00000130307fc00 bsp=
=E0000013030792b0
> > [    5.102739]  [<a00000010052f1a0>] ide_cd_do_request+0x980/0x1420
> > [    5.102742]                                 sp=E00000130307fc00 bsp=
=E000001303079238
> > [    5.117064]  [<a00000010050fe00>] ide_do_request+0xca0/0x1d00
> > [    5.117066]                                 sp=E00000130307fc00 bsp=
=E0000013030791a0
> > [    5.131105]  [<a000000100511580>] do_ide_request+0x40/0x60
> > [    5.131107]                                 sp=E00000130307fc30 bsp=
=E000001303079180
> > [    5.144897]  [<a000000100384780>] elv_insert+0x280/0x5c0
> > [    5.144900]                                 sp=E00000130307fc30 bsp=
=E000001303079148
> > [    5.158507]  [<a000000100384c40>] __elv_add_request+0x180/0x240
> > [    5.158509]                                 sp=E00000130307fc30 bsp=
=E000001303079110
> > [    5.172733]  [<a000000100391730>] blk_execute_rq_nowait+0xd0/0x1e0
> > [    5.172734]                                 sp=E00000130307fc30 bsp=
=E0000013030790d0
> > [    5.187220]  [<a000000100391910>] blk_execute_rq+0xd0/0x240
> > [    5.187221]                                 sp=E00000130307fc30 bsp=
=E000001303079090
> > [    5.201091]  [<a000000100531f70>] ide_cd_queue_pc+0x130/0x2e0
> > [    5.201093]                                 sp=E00000130307fcc0 bsp=
=E000001303078fd0
> > [    5.215137]  [<a0000001005342f0>] ide_cdrom_packet+0x130/0x180
> > [    5.215139]                                 sp=E00000130307fd00 bsp=
=E000001303078f78
> > [    5.229281]  [<a000000100593080>] cdrom_mode_sense+0xc0/0xe0
> > [    5.229283]                                 sp=E00000130307fd10 bsp=
=E000001303078f40
> > [    5.243239]  [<a00000010052d9c0>] ide_cdrom_get_capabilities+0x80/0x=
c0
> > [    5.243240]                                 sp=E00000130307fd10 bsp=
=E000001303078f10
> > [    5.258084]  [<a000000100533890>] ide_cd_probe+0x810/0xf40
> > [    5.258086]                                 sp=E00000130307fd50 bsp=
=E000001303078e90
> > [    5.273709]  [<a00000010050a510>] generic_ide_probe+0x70/0xa0
> > [    5.273711]                                 sp=E00000130307fdc0 bsp=
=E000001303078e70
> > [    5.287774]  [<a0000001004bdaf0>] driver_probe_device+0x190/0x3a0
> > [    5.287775]                                 sp=E00000130307fdc0 bsp=
=E000001303078e28
> > [    5.302163]  [<a0000001004bdd80>] __driver_attach+0x80/0xe0
> > [    5.302164]                                 sp=E00000130307fdc0 bsp=
=E000001303078de8
> > [    5.316032]  [<a0000001004bc5a0>] bus_for_each_dev+0xc0/0x140
> > [    5.316034]                                 sp=E00000130307fdc0 bsp=
=E000001303078db0
> > [    5.330072]  [<a0000001004bd700>] driver_attach+0x40/0x60
> > [    5.330074]                                 sp=E00000130307fde0 bsp=
=E000001303078d90
> > [    5.343761]  [<a0000001004bd290>] bus_add_driver+0x370/0x4a0
> > [    5.343763]                                 sp=E00000130307fde0 bsp=
=E000001303078d48
> > [    5.357720]  [<a0000001004be3d0>] driver_register+0xd0/0x340
> > [    5.357721]                                 sp=E00000130307fde0 bsp=
=E000001303078d00
> > [    5.371693]  [<a0000001009a3ea0>] ide_cdrom_init+0x20/0x40
> > [    5.371695]                                 sp=E00000130307fde0 bsp=
=E000001303078ce8
> > [    5.385475]  [<a00000010000a5a0>] do_one_initcall+0x60/0x380
> > [    5.385477]                                 sp=E00000130307fde0 bsp=
=E000001303078ca8
> > [    5.399445]  [<a0000001009645b0>] kernel_init+0x370/0x420
> > [    5.399447]                                 sp=E00000130307fe20 bsp=
=E000001303078c68
> > [    5.413148]  [<a000000100013590>] kernel_thread_helper+0xd0/0x100
> > [    5.413149]                                 sp=E00000130307fe30 bsp=
=E000001303078c40
> > [    5.427547]  [<a00000010000a4c0>] start_kernel_thread+0x20/0x40
> > [    5.427548]                                 sp=E00000130307fe30 bsp=
=E000001303078c40
> >=20
> > We are trying to send a sense command to the device and the buffer we
> > use (which is rq->cmd) is what is unaligned, I believe. I'm not sure how
> > useful I can be going forward...
> >=20
> > Thanks,
> > Nish
> >=20
> > --=20
> > Nishanth Aravamudan <nacc@us.ibm.com>
> > IBM Linux Technology Center

--=20
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center
