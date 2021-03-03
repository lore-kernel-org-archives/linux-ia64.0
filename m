From: <Don.Brace@microchip.com>
Date: Wed, 03 Mar 2021 15:42:39 +0000
Subject: RE: [bisected] 5.12-rc1 hpsa regression: "scsi: hpsa: Correct dev cmds outstanding for retried cmds"
Message-Id: <SN6PR11MB284899AF468190BE10031BA7E1989@SN6PR11MB2848.namprd11.prod.outlook.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210222230519.73f3e239@sf>
        <cc658b61-530e-90bf-3858-36cc60468a24@kernel.dk>
        <8decdd2e-a380-9951-3ebb-2bc3e48aa1c3@physik.fu-berlin.de>
        <20210223083507.43b5a6dd@sf>
        <51cbf584-07ef-1e62-7a3b-81494a04faa6@physik.fu-berlin.de>
        <9441757f-d4bc-a5b5-5fb0-967c9aaca693@physik.fu-berlin.de>
        <20210223192743.0198d4a9@sf>    <20210302222630.5056f243@sf>
        <25dfced0-88b2-b5b3-f1b6-8b8a9931bf90@physik.fu-berlin.de>
 <20210303002236.2f4ec01f@sf>
In-Reply-To: <20210303002236.2f4ec01f@sf>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: slyich@gmail.com, glaubitz@physik.fu-berlin.de
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, jszczype@redhat.com, Scott.Benesh@microchip.com, Scott.Teel@microchip.com, thenzl@redhat.com, martin.petersen@oracle.com

-----Original Message-----
From: Sergei Trofimovich [mailto:slyich@gmail.com] 
Sent: Tuesday, March 2, 2021 6:23 PM
To: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>; Don Brace - C33706 <Don.Brace@microchip.com>
Cc: linux-ia64@vger.kernel.org; linux-kernel@vger.kernel.org; Joe Szczypek <jszczype@redhat.com>; Scott Benesh - C33703 <Scott.Benesh@microchip.com>; Scott Teel - C33730 <Scott.Teel@microchip.com>; Tomas Henzl <thenzl@redhat.com>; Martin K. Petersen <martin.petersen@oracle.com>
Subject: [bisected] 5.12-rc1 hpsa regression: "scsi: hpsa: Correct dev cmds outstanding for retried cmds" breaks hpsa P600

EXTERNAL EMAIL: Do not click links or open attachments unless you know the content is safe

On Tue, 2 Mar 2021 23:31:32 +0100
John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de> wrote:

> Hi Sergei!
>
> On 3/2/21 11:26 PM, Sergei Trofimovich wrote:
> > Gave v5.12-rc1 a try today and got a similar boot failure around 
> > hpsa queue initialization, but my failure is later:
> >     https://dev.gentoo.org/~slyfox/configs/guppy-dmesg-5.12-rc1
> > Maybe I get different error because I flipped on most debugging 
> > kernel options :)
> >
> > Looks like 'ERROR: Invalid distance value range' while being very 
> > scary are harmless. It's just a new spammy way for kernel to report 
> > lack of NUMA config on the machine (no SRAT and SLIT ACPI tables).
> >
> > At least I get hpsa detected on PCI bus. But I guess it's discovered 
> > configuration is very wrong as I get unaligned accesses:
> >     [   19.811570] kernel unaligned access to 0xe000000105dd8295, ip=0xa000000100b874d1
> >
> > Bisecting now.
>
> Sounds good. I guess we should get Jens' fix for the signal regression 
> merged as well as your two fixes for strace.

"bisected" (cheated halfway through) and verified that reverting
f749d8b7a9896bc6e5ffe104cc64345037e0b152 makes rx3600 boot again.

CCing authors who might be able to help us here.

commit f749d8b7a9896bc6e5ffe104cc64345037e0b152
Author: Don Brace <don.brace@microchip.com>
Date:   Mon Feb 15 16:26:57 2021 -0600

    scsi: hpsa: Correct dev cmds outstanding for retried cmds

    Prevent incrementing device->commands_outstanding for ioaccel command
    retries that are driver initiated.  If the command goes through the retry
    path, the device->commands_outstanding counter has already accounted for
    the number of commands outstanding to the device.  Only commands going
    through function hpsa_cmd_resolve_events decrement this counter.

     - ioaccel commands go to either HBA disks or to logical volumes comprised
       of SSDs.

    The extra increment is causing device resets to hang.

     - Resets wait for all device outstanding commands to complete before
       returning.

    Replace unused field abort_pending with retry_pending. This is a
    maintenance driver so these changes have the least impact/risk.

    Link: https://lore.kernel.org/r/161342801747.29388.13045495968308188518.stgit@brunhilda
    Tested-by: Joe Szczypek <jszczype@redhat.com>
    Reviewed-by: Scott Benesh <scott.benesh@microchip.com>
    Reviewed-by: Scott Teel <scott.teel@microchip.com>
    Reviewed-by: Tomas Henzl <thenzl@redhat.com>
    Signed-off-by: Don Brace <don.brace@microchip.com>
    Signed-off-by: Martin K. Petersen <martin.petersen@oracle.com>

Don, do you happen to know why this patch caused some controller init failure for device
    14:01.0 RAID bus controller: Hewlett-Packard Company Smart Array P600 ?

Boot failure: https://dev.gentoo.org/~slyfox/configs/guppy-dmesg-5.12-rc1
Boot success: https://dev.gentoo.org/~slyfox/configs/guppy-dmesg-5.12-rc1-good

The difference between the two boots is
f749d8b7a9896bc6e5ffe104cc64345037e0b152 reverted on top of 5.12-rc1 in -good case.

Looks like hpsa controller fails to initialize in bad case (could be a race?).

--

  Sergei

Don:
I see aligned access. Let me run pahole to see if anything jumps out.
What controller are you using?
