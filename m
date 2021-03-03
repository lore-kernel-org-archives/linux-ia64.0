From: Sergei Trofimovich <slyich@gmail.com>
Date: Wed, 03 Mar 2021 08:55:33 +0000
Subject: Re: [bisected] 5.12-rc1 hpsa regression: "scsi: hpsa: Correct dev cmds outstanding for retried cmds"
Message-Id: <20210303085533.505b1590@sf>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210222230519.73f3e239@sf>
        <cc658b61-530e-90bf-3858-36cc60468a24@kernel.dk>
        <8decdd2e-a380-9951-3ebb-2bc3e48aa1c3@physik.fu-berlin.de>
        <20210223083507.43b5a6dd@sf>
        <51cbf584-07ef-1e62-7a3b-81494a04faa6@physik.fu-berlin.de>
        <9441757f-d4bc-a5b5-5fb0-967c9aaca693@physik.fu-berlin.de>
        <20210223192743.0198d4a9@sf>
        <20210302222630.5056f243@sf>
        <25dfced0-88b2-b5b3-f1b6-8b8a9931bf90@physik.fu-berlin.de>
        <20210303002236.2f4ec01f@sf>
In-Reply-To: <20210303002236.2f4ec01f@sf>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, Don Brace <don.brace@microchip.com>, storagedev@microchip.com, linux-scsi@vger.kernel.org
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Joe Szczypek <jszczype@redhat.com>, Scott Benesh <scott.benesh@microchip.com>, Scott Teel <scott.teel@microchip.com>, Tomas Henzl <thenzl@redhat.com>, "Martin K. Petersen" <martin.petersen@oracle.com>

On Wed, 3 Mar 2021 00:22:36 +0000
Sergei Trofimovich <slyich@gmail.com> wrote:

> On Tue, 2 Mar 2021 23:31:32 +0100
> John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de> wrote:
>=20
> > Hi Sergei!
> >=20
> > On 3/2/21 11:26 PM, Sergei Trofimovich wrote: =20
> > > Gave v5.12-rc1 a try today and got a similar boot failure around
> > > hpsa queue initialization, but my failure is later:
> > >     https://dev.gentoo.org/~slyfox/configs/guppy-dmesg-5.12-rc1
> > > Maybe I get different error because I flipped on most debugging
> > > kernel options :)
> > >=20
> > > Looks like 'ERROR: Invalid distance value range' while being
> > > very scary are harmless. It's just a new spammy way for kernel
> > > to report lack of NUMA config on the machine (no SRAT and SLIT
> > > ACPI tables).
> > >=20
> > > At least I get hpsa detected on PCI bus. But I guess it's discovered
> > > configuration is very wrong as I get unaligned accesses:
> > >     [   19.811570] kernel unaligned access to 0xe000000105dd8295, ip=
=3D0xa000000100b874d1
> > >=20
> > > Bisecting now.   =20
> >=20
> > Sounds good. I guess we should get Jens' fix for the signal regression
> > merged as well as your two fixes for strace. =20
>=20
> "bisected" (cheated halfway through) and verified that reverting
> f749d8b7a9896bc6e5ffe104cc64345037e0b152 makes rx3600 boot again.
>=20
> CCing authors who might be able to help us here.
>=20
> commit f749d8b7a9896bc6e5ffe104cc64345037e0b152
> Author: Don Brace <don.brace@microchip.com>
> Date:   Mon Feb 15 16:26:57 2021 -0600
>=20
>     scsi: hpsa: Correct dev cmds outstanding for retried cmds
>=20
>     Prevent incrementing device->commands_outstanding for ioaccel command
>     retries that are driver initiated.  If the command goes through the r=
etry
>     path, the device->commands_outstanding counter has already accounted =
for
>     the number of commands outstanding to the device.  Only commands going
>     through function hpsa_cmd_resolve_events decrement this counter.
>=20
>      - ioaccel commands go to either HBA disks or to logical volumes comp=
rised
>        of SSDs.
>=20
>     The extra increment is causing device resets to hang.
>=20
>      - Resets wait for all device outstanding commands to complete before
>        returning.
>=20
>     Replace unused field abort_pending with retry_pending. This is a
>     maintenance driver so these changes have the least impact/risk.
>=20
>     Link: https://lore.kernel.org/r/161342801747.29388.130454959683081885=
18.stgit@brunhilda
>     Tested-by: Joe Szczypek <jszczype@redhat.com>
>     Reviewed-by: Scott Benesh <scott.benesh@microchip.com>
>     Reviewed-by: Scott Teel <scott.teel@microchip.com>
>     Reviewed-by: Tomas Henzl <thenzl@redhat.com>
>     Signed-off-by: Don Brace <don.brace@microchip.com>
>     Signed-off-by: Martin K. Petersen <martin.petersen@oracle.com>
>=20
> Don, do you happen to know why this patch caused some controller init fai=
lure
> for device
>     14:01.0 RAID bus controller: Hewlett-Packard Company Smart Array P600
> ?
>=20
> Boot failure: https://dev.gentoo.org/~slyfox/configs/guppy-dmesg-5.12-rc1
> Boot success: https://dev.gentoo.org/~slyfox/configs/guppy-dmesg-5.12-rc1=
-good
>=20
> The difference between the two boots is=20
> f749d8b7a9896bc6e5ffe104cc64345037e0b152 reverted on top of 5.12-rc1
> in -good case.
>=20
> Looks like hpsa controller fails to initialize in bad case (could be a ra=
ce?).

Also CCing hpsa maintainer mailing lists.

Looking more into the suspect commit
    https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/comm=
it/?id=F749d8b7a9896bc6e5ffe104cc64345037e0b152
it roughly does the:

@@ -448,7 +448,7 @@ struct CommandList {
 	 */
 	struct hpsa_scsi_dev_t *phys_disk;
=20
-	int abort_pending;
+	bool retry_pending;
 	struct hpsa_scsi_dev_t *device;
 	atomic_t refcount; /* Must be last to avoid memset in hpsa_cmd_init() */
 } __aligned(COMMANDLIST_ALIGNMENT);
...
@@ -1151,7 +1151,10 @@ static void __enqueue_cmd_and_start_io(struct ctlr_i=
nfo *h,
 {
        dial_down_lockup_detection_during_fw_flash(h, c);
        atomic_inc(&h->commands_outstanding);
-       if (c->device)
+       /*
+        * Check to see if the command is being retried.
+        */
+       if (c->device && !c->retry_pending)
                atomic_inc(&c->device->commands_outstanding);

But I don't immediately see anything wrong with it.

--=20

  Sergei
