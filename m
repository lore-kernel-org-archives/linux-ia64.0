From: Tomas Henzl <thenzl@redhat.com>
Date: Fri, 05 Mar 2021 13:26:54 +0000
Subject: Re: [bisected] 5.12-rc1 hpsa regression: "scsi: hpsa: Correct dev cmds outstanding for retried cmds"
Message-Id: <5532f9ab-7555-d51b-f4d5-f9b72a61f248@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210222230519.73f3e239@sf>
 <cc658b61-530e-90bf-3858-36cc60468a24@kernel.dk>
 <8decdd2e-a380-9951-3ebb-2bc3e48aa1c3@physik.fu-berlin.de>
 <20210223083507.43b5a6dd@sf>
 <51cbf584-07ef-1e62-7a3b-81494a04faa6@physik.fu-berlin.de>
 <9441757f-d4bc-a5b5-5fb0-967c9aaca693@physik.fu-berlin.de>
 <20210223192743.0198d4a9@sf> <20210302222630.5056f243@sf>
 <25dfced0-88b2-b5b3-f1b6-8b8a9931bf90@physik.fu-berlin.de>
 <20210303002236.2f4ec01f@sf> <20210303085533.505b1590@sf>
 <SN6PR11MB284885A5751845EEA290BFCFE1989@SN6PR11MB2848.namprd11.prod.outlook.com>
 <20210303220401.501449e5@sf>
 <SN6PR11MB2848371902B9488289A7B4C7E1979@SN6PR11MB2848.namprd11.prod.outlook.com>
In-Reply-To: <SN6PR11MB2848371902B9488289A7B4C7E1979@SN6PR11MB2848.namprd11.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Don.Brace@microchip.com, slyich@gmail.com
Cc: glaubitz@physik.fu-berlin.de, storagedev@microchip.com, linux-scsi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, jszczype@redhat.com, Scott.Benesh@microchip.com, Scott.Teel@microchip.com, martin.petersen@oracle.com

On 3/4/21 6:00 PM, Don.Brace@microchip.com wrote:
> -----Original Message-----
> From: Sergei Trofimovich [mailto:slyich@gmail.com] 
> Sent: Wednesday, March 3, 2021 4:04 PM
> To: Don Brace - C33706 <Don.Brace@microchip.com>
> Cc: glaubitz@physik.fu-berlin.de; storagedev <storagedev@microchip.com>; linux-scsi@vger.kernel.org; linux-ia64@vger.kernel.org; linux-kernel@vger.kernel.org; jszczype@redhat.com; Scott Benesh - C33703 <Scott.Benesh@microchip.com>; Scott Teel - C33730 <Scott.Teel@microchip.com>; thenzl@redhat.com; martin.petersen@oracle.com
> Subject: Re: [bisected] 5.12-rc1 hpsa regression: "scsi: hpsa: Correct dev cmds outstanding for retried cmds" breaks hpsa P600
> 
> Glad to hear the patch works. 
> The P600 is an unsupported controller that was removed some time ago (by us) and re-added in this patch:
> commit 135ae6edeb51979d0998daf1357f149a7d6ebb08 scsi: hpsa: add support for legacy boards
> Author: Hannes Reinecke <hare@suse.de>
> Date:   Tue Aug 15 08:58:04 2017 +0200
> 
> So, when testing the original patch, I no longer have a P600 to test with. It used to be supported by our obsoleted cciss driver.

Do you know why this is specific to P600, since the struct is used only
internally in the driver and not used to communicate with the controller
or am I wrong?

> 
> Since patch f749d8b7a9896bc6e5ffe104cc64345037e0b152 scsi: hpsa: Correct dev cmds outstanding for retried cmds has
> already been applied to Martin Petersons 5.13/scsi-queue, perhaps it would be better to send up another patch to correct your alignment issue on these legacy boards.
> 
> Wondering what others think about this?

I agree with you I'd prefer a new patch.

Thanks,
Tomas

> 
> Thanks,
> Don
> 
