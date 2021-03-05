From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Fri, 05 Mar 2021 09:22:20 +0000
Subject: Re: [bisected] 5.12-rc1 hpsa regression: "scsi: hpsa: Correct dev cmds outstanding for retried cmds"
Message-Id: <CAMuHMdVLFfSoC-UYW+3sijeZhLf9xt3rqS=7LTYhzX_1RDxpYA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210222230519.73f3e239@sf> <cc658b61-530e-90bf-3858-36cc60468a24@kernel.dk>
 <8decdd2e-a380-9951-3ebb-2bc3e48aa1c3@physik.fu-berlin.de>
 <20210223083507.43b5a6dd@sf> <51cbf584-07ef-1e62-7a3b-81494a04faa6@physik.fu-berlin.de>
 <9441757f-d4bc-a5b5-5fb0-967c9aaca693@physik.fu-berlin.de>
 <20210223192743.0198d4a9@sf> <20210302222630.5056f243@sf> <25dfced0-88b2-b5b3-f1b6-8b8a9931bf90@physik.fu-berlin.de>
 <20210303002236.2f4ec01f@sf> <20210303085533.505b1590@sf> <SN6PR11MB284885A5751845EEA290BFCFE1989@SN6PR11MB2848.namprd11.prod.outlook.com>
In-Reply-To: <SN6PR11MB284885A5751845EEA290BFCFE1989@SN6PR11MB2848.namprd11.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Don.Brace@microchip.com
Cc: slyich@gmail.com, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, storagedev@microchip.com, scsi <linux-scsi@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, jszczype@redhat.com, Scott.Benesh@microchip.com, Scott.Teel@microchip.com, thenzl@redhat.com, "Martin K. Petersen" <martin.petersen@oracle.com>

Hi Don,

On Fri, Mar 5, 2021 at 12:26 AM <Don.Brace@microchip.com> wrote:
> -----Original Message-----
> From: Sergei Trofimovich [mailto:slyich@gmail.com]
> Sent: Wednesday, March 3, 2021 2:56 AM
> To: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>; Don Brace - C33706 <Don.Brace@microchip.com>; storagedev <storagedev@microchip.com>; linux-scsi@vger.kernel.org
> Cc: linux-ia64@vger.kernel.org; linux-kernel@vger.kernel.org; Joe Szczypek <jszczype@redhat.com>; Scott Benesh - C33703 <Scott.Benesh@microchip.com>; Scott Teel - C33730 <Scott.Teel@microchip.com>; Tomas Henzl <thenzl@redhat.com>; Martin K. Petersen <martin.petersen@oracle.com>
> Subject: Re: [bisected] 5.12-rc1 hpsa regression: "scsi: hpsa: Correct dev cmds outstanding for retried cmds" breaks hpsa P600
>
> EXTERNAL EMAIL: Do not click links or open attachments unless you know the content is safe
>
> On Wed, 3 Mar 2021 00:22:36 +0000
> Sergei Trofimovich <slyich@gmail.com> wrote:
>
> > On Tue, 2 Mar 2021 23:31:32 +0100
> > John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de> wrote:
> >
> > > Hi Sergei!
> > >
> > > On 3/2/21 11:26 PM, Sergei Trofimovich wrote:
> > > > Gave v5.12-rc1 a try today and got a similar boot failure around
> > > > hpsa queue initialization, but my failure is later:
> > > >     https://dev.gentoo.org/~slyfox/configs/guppy-dmesg-5.12-rc1
> > > > Maybe I get different error because I flipped on most debugging
> > > > kernel options :)
> > > >
> > > > Looks like 'ERROR: Invalid distance value range' while being very
> > > > scary are harmless. It's just a new spammy way for kernel to
> > > > report lack of NUMA config on the machine (no SRAT and SLIT ACPI
> > > > tables).
> > > >
> > > > At least I get hpsa detected on PCI bus. But I guess it's
> > > > discovered configuration is very wrong as I get unaligned accesses:
> > > >     [   19.811570] kernel unaligned access to 0xe000000105dd8295, ip=0xa000000100b874d1
>
> Running pahole before the patch:
>
> struct CommandList {
>         struct CommandListHeader Header;                 /*     0    20 */
>         struct RequestBlock Request;                     /*    20    20 */
>         struct ErrDescriptor ErrDesc;                    /*    40    12 */
>         struct SGDescriptor SG[32];                      /*    52   512 */
>         /* --- cacheline 8 boundary (512 bytes) was 52 bytes ago --- */
>         u32                        busaddr;              /*   564     4 */
>         struct ErrorInfo *         err_info;             /*   568     8 */
>         /* --- cacheline 9 boundary (576 bytes) --- */
>         struct ctlr_info *         h;                    /*   576     8 */
>         int                        cmd_type;             /*   584     4 */
>         long int                   cmdindex;             /*   588     8 */
>         struct completion *        waiting;              /*   596     8 */
>         struct scsi_cmnd *         scsi_cmd;             /*   604     8 */
>         struct work_struct work;                         /*   612    32 */
>         /* --- cacheline 10 boundary (640 bytes) was 4 bytes ago --- */
>         struct hpsa_scsi_dev_t *   phys_disk;            /*   644     8 */
>         int                        abort_pending;        /*   652     4 */
>         struct hpsa_scsi_dev_t *   device;               /*   656     8 */
>         atomic_t                   refcount;             /*   664     4 */
>
>         /* size: 768, cachelines: 12, members: 16 */
>         /* padding: 100 */
> } __attribute__((__aligned__(128)));
>
> Pahole after the patch:
>
> struct CommandList {
>         struct CommandListHeader Header;                 /*     0    20 */
>         struct RequestBlock Request;                     /*    20    20 */
>         struct ErrDescriptor ErrDesc;                    /*    40    12 */
>         struct SGDescriptor SG[32];                      /*    52   512 */
>         /* --- cacheline 8 boundary (512 bytes) was 52 bytes ago --- */
>         u32                        busaddr;              /*   564     4 */
>         struct ErrorInfo *         err_info;             /*   568     8 */
>         /* --- cacheline 9 boundary (576 bytes) --- */
>         struct ctlr_info *         h;                    /*   576     8 */
>         int                        cmd_type;             /*   584     4 */
>         long int                   cmdindex;             /*   588     8 */
>         struct completion *        waiting;              /*   596     8 */
>         struct scsi_cmnd *         scsi_cmd;             /*   604     8 */
>         struct work_struct work;                         /*   612    32 */
>         /* --- cacheline 10 boundary (640 bytes) was 4 bytes ago --- */
>         struct hpsa_scsi_dev_t *   phys_disk;            /*   644     8 */
>         struct hpsa_scsi_dev_t *   device;               /*   652     8 */
>         bool                       retry_pending;        /*   660     1 */
>         atomic_t                   refcount;             /*   661     4 */

How come this atomic_t is no longer aligned to its natural alignment?

>
>         /* size: 768, cachelines: 12, members: 16 */
>         /* padding: 103 */
> } __attribute__((__aligned__(128)));

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
