From: <Don.Brace@microchip.com>
Date: Wed, 03 Mar 2021 17:33:13 +0000
Subject: RE: [bisected] 5.12-rc1 hpsa regression: "scsi: hpsa: Correct dev cmds outstanding for retried cmds"
Message-Id: <SN6PR11MB284885A5751845EEA290BFCFE1989@SN6PR11MB2848.namprd11.prod.outlook.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="_002_SN6PR11MB284885A5751845EEA290BFCFE1989SN6PR11MB2848namp_"
List-Id: <linux-ia64.vger.kernel.org>
References: <20210222230519.73f3e239@sf>
        <cc658b61-530e-90bf-3858-36cc60468a24@kernel.dk>
        <8decdd2e-a380-9951-3ebb-2bc3e48aa1c3@physik.fu-berlin.de>
        <20210223083507.43b5a6dd@sf>
        <51cbf584-07ef-1e62-7a3b-81494a04faa6@physik.fu-berlin.de>
        <9441757f-d4bc-a5b5-5fb0-967c9aaca693@physik.fu-berlin.de>
        <20210223192743.0198d4a9@sf>    <20210302222630.5056f243@sf>
        <25dfced0-88b2-b5b3-f1b6-8b8a9931bf90@physik.fu-berlin.de>
        <20210303002236.2f4ec01f@sf> <20210303085533.505b1590@sf>
In-Reply-To: <20210303085533.505b1590@sf>
To: slyich@gmail.com, glaubitz@physik.fu-berlin.de, storagedev@microchip.com, linux-scsi@vger.kernel.org
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, jszczype@redhat.com, Scott.Benesh@microchip.com, Scott.Teel@microchip.com, thenzl@redhat.com, martin.petersen@oracle.com

--_002_SN6PR11MB284885A5751845EEA290BFCFE1989SN6PR11MB2848namp_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

-----Original Message-----
From: Sergei Trofimovich [mailto:slyich@gmail.com]=20
Sent: Wednesday, March 3, 2021 2:56 AM
To: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>; Don Brace - C=
33706 <Don.Brace@microchip.com>; storagedev <storagedev@microchip.com>; lin=
ux-scsi@vger.kernel.org
Cc: linux-ia64@vger.kernel.org; linux-kernel@vger.kernel.org; Joe Szczypek =
<jszczype@redhat.com>; Scott Benesh - C33703 <Scott.Benesh@microchip.com>; =
Scott Teel - C33730 <Scott.Teel@microchip.com>; Tomas Henzl <thenzl@redhat.=
com>; Martin K. Petersen <martin.petersen@oracle.com>
Subject: Re: [bisected] 5.12-rc1 hpsa regression: "scsi: hpsa: Correct dev =
cmds outstanding for retried cmds" breaks hpsa P600

EXTERNAL EMAIL: Do not click links or open attachments unless you know the =
content is safe

On Wed, 3 Mar 2021 00:22:36 +0000
Sergei Trofimovich <slyich@gmail.com> wrote:

> On Tue, 2 Mar 2021 23:31:32 +0100
> John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de> wrote:
>
> > Hi Sergei!
> >
> > On 3/2/21 11:26 PM, Sergei Trofimovich wrote:
> > > Gave v5.12-rc1 a try today and got a similar boot failure around=20
> > > hpsa queue initialization, but my failure is later:
> > >     https://dev.gentoo.org/~slyfox/configs/guppy-dmesg-5.12-rc1
> > > Maybe I get different error because I flipped on most debugging=20
> > > kernel options :)
> > >
> > > Looks like 'ERROR: Invalid distance value range' while being very=20
> > > scary are harmless. It's just a new spammy way for kernel to=20
> > > report lack of NUMA config on the machine (no SRAT and SLIT ACPI=20
> > > tables).
> > >
> > > At least I get hpsa detected on PCI bus. But I guess it's=20
> > > discovered configuration is very wrong as I get unaligned accesses:
> > >     [   19.811570] kernel unaligned access to 0xe000000105dd8295, ip=
=3D0xa000000100b874d1

Running pahole before the patch:

struct CommandList {
        struct CommandListHeader Header;                 /*     0    20 */
        struct RequestBlock Request;                     /*    20    20 */
        struct ErrDescriptor ErrDesc;                    /*    40    12 */
        struct SGDescriptor SG[32];                      /*    52   512 */
        /* --- cacheline 8 boundary (512 bytes) was 52 bytes ago --- */
        u32                        busaddr;              /*   564     4 */
        struct ErrorInfo *         err_info;             /*   568     8 */
        /* --- cacheline 9 boundary (576 bytes) --- */
        struct ctlr_info *         h;                    /*   576     8 */
        int                        cmd_type;             /*   584     4 */
        long int                   cmdindex;             /*   588     8 */
        struct completion *        waiting;              /*   596     8 */
        struct scsi_cmnd *         scsi_cmd;             /*   604     8 */
        struct work_struct work;                         /*   612    32 */
        /* --- cacheline 10 boundary (640 bytes) was 4 bytes ago --- */
        struct hpsa_scsi_dev_t *   phys_disk;            /*   644     8 */
        int                        abort_pending;        /*   652     4 */
        struct hpsa_scsi_dev_t *   device;               /*   656     8 */
        atomic_t                   refcount;             /*   664     4 */

        /* size: 768, cachelines: 12, members: 16 */
        /* padding: 100 */
} __attribute__((__aligned__(128)));

Pahole after the patch:

struct CommandList {
        struct CommandListHeader Header;                 /*     0    20 */
        struct RequestBlock Request;                     /*    20    20 */
        struct ErrDescriptor ErrDesc;                    /*    40    12 */
        struct SGDescriptor SG[32];                      /*    52   512 */
        /* --- cacheline 8 boundary (512 bytes) was 52 bytes ago --- */
        u32                        busaddr;              /*   564     4 */
        struct ErrorInfo *         err_info;             /*   568     8 */
        /* --- cacheline 9 boundary (576 bytes) --- */
        struct ctlr_info *         h;                    /*   576     8 */
        int                        cmd_type;             /*   584     4 */
        long int                   cmdindex;             /*   588     8 */
        struct completion *        waiting;              /*   596     8 */
        struct scsi_cmnd *         scsi_cmd;             /*   604     8 */
        struct work_struct work;                         /*   612    32 */
        /* --- cacheline 10 boundary (640 bytes) was 4 bytes ago --- */
        struct hpsa_scsi_dev_t *   phys_disk;            /*   644     8 */
        struct hpsa_scsi_dev_t *   device;               /*   652     8 */
        bool                       retry_pending;        /*   660     1 */
        atomic_t                   refcount;             /*   661     4 */

        /* size: 768, cachelines: 12, members: 16 */
        /* padding: 103 */
} __attribute__((__aligned__(128)));

So, I did replace abort_pending field (an int) with retry_pending (bool)
Can I send you a patch to just rename abort_pending to retry_pending using =
the same type and position?
It will mean some minor code changes in the driver...

With the above changes, pahole is the same
struct CommandList {
        struct CommandListHeader Header;                 /*     0    20 */
        struct RequestBlock Request;                     /*    20    20 */
        struct ErrDescriptor ErrDesc;                    /*    40    12 */
        struct SGDescriptor SG[32];                      /*    52   512 */
        /* --- cacheline 8 boundary (512 bytes) was 52 bytes ago --- */
        u32                        busaddr;              /*   564     4 */
        struct ErrorInfo *         err_info;             /*   568     8 */
        /* --- cacheline 9 boundary (576 bytes) --- */
        struct ctlr_info *         h;                    /*   576     8 */
        int                        cmd_type;             /*   584     4 */
        long int                   cmdindex;             /*   588     8 */
        struct completion *        waiting;              /*   596     8 */
        struct scsi_cmnd *         scsi_cmd;             /*   604     8 */
        struct work_struct work;                         /*   612    32 */
        /* --- cacheline 10 boundary (640 bytes) was 4 bytes ago --- */
        struct hpsa_scsi_dev_t *   phys_disk;            /*   644     8 */
        int                        retry_pending;        /*   652     4 */
        struct hpsa_scsi_dev_t *   device;               /*   656     8 */
        atomic_t                   refcount;             /*   664     4 */

        /* size: 768, cachelines: 12, members: 16 */
        /* padding: 100 */
} __attribute__((__aligned__(128)));


> > >
> > > Bisecting now.
> >
> > Sounds good. I guess we should get Jens' fix for the signal=20
> > regression merged as well as your two fixes for strace.
>
> "bisected" (cheated halfway through) and verified that reverting
> f749d8b7a9896bc6e5ffe104cc64345037e0b152 makes rx3600 boot again.
>
> CCing authors who might be able to help us here.
>
> commit f749d8b7a9896bc6e5ffe104cc64345037e0b152
> Author: Don Brace <don.brace@microchip.com>
> Date:   Mon Feb 15 16:26:57 2021 -0600
>
>     scsi: hpsa: Correct dev cmds outstanding for retried cmds
>
>     Prevent incrementing device->commands_outstanding for ioaccel command
>     retries that are driver initiated.  If the command goes through the r=
etry
>     path, the device->commands_outstanding counter has already accounted =
for
>     the number of commands outstanding to the device.  Only commands goin=
g
>     through function hpsa_cmd_resolve_events decrement this counter.
>
>      - ioaccel commands go to either HBA disks or to logical volumes comp=
rised
>        of SSDs.
>
>     The extra increment is causing device resets to hang.
>
>      - Resets wait for all device outstanding commands to complete before
>        returning.
>
>     Replace unused field abort_pending with retry_pending. This is a
>     maintenance driver so these changes have the least impact/risk.
>
>     Link: https://lore.kernel.org/r/161342801747.29388.130454959683081885=
18.stgit@brunhilda
>     Tested-by: Joe Szczypek <jszczype@redhat.com>
>     Reviewed-by: Scott Benesh <scott.benesh@microchip.com>
>     Reviewed-by: Scott Teel <scott.teel@microchip.com>
>     Reviewed-by: Tomas Henzl <thenzl@redhat.com>
>     Signed-off-by: Don Brace <don.brace@microchip.com>
>     Signed-off-by: Martin K. Petersen <martin.petersen@oracle.com>
>
> Don, do you happen to know why this patch caused some controller init=20
> failure for device
>     14:01.0 RAID bus controller: Hewlett-Packard Company Smart Array=20
> P600 ?
>
> Boot failure:=20
> https://dev.gentoo.org/~slyfox/configs/guppy-dmesg-5.12-rc1
> Boot success:=20
> https://dev.gentoo.org/~slyfox/configs/guppy-dmesg-5.12-rc1-good
>
> The difference between the two boots is
> f749d8b7a9896bc6e5ffe104cc64345037e0b152 reverted on top of 5.12-rc1=20
> in -good case.
>
> Looks like hpsa controller fails to initialize in bad case (could be a ra=
ce?).

Also CCing hpsa maintainer mailing lists.

Looking more into the suspect commit
    https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/comm=
it/?id=3Df749d8b7a9896bc6e5ffe104cc64345037e0b152
it roughly does the:

@@ -448,7 +448,7 @@ struct CommandList {
         */
        struct hpsa_scsi_dev_t *phys_disk;

-       int abort_pending;
+       bool retry_pending;
        struct hpsa_scsi_dev_t *device;
        atomic_t refcount; /* Must be last to avoid memset in hpsa_cmd_init=
() */  } __aligned(COMMANDLIST_ALIGNMENT); ...
@@ -1151,7 +1151,10 @@ static void __enqueue_cmd_and_start_io(struct ctlr_i=
nfo *h,  {
        dial_down_lockup_detection_during_fw_flash(h, c);
        atomic_inc(&h->commands_outstanding);
-       if (c->device)
+       /*
+        * Check to see if the command is being retried.
+        */
+       if (c->device && !c->retry_pending)
                atomic_inc(&c->device->commands_outstanding);

But I don't immediately see anything wrong with it.

--

  Sergei

--_002_SN6PR11MB284885A5751845EEA290BFCFE1989SN6PR11MB2848namp_
Content-Type: application/octet-stream;
	name="hpsa-correct-dev-cmd-outstanding-for-retried-cmds-alignment-update"
Content-Description: hpsa-correct-dev-cmd-outstanding-for-retried-cmds-alignment-update
Content-Disposition: attachment;
	filename="hpsa-correct-dev-cmd-outstanding-for-retried-cmds-alignment-update";
	size=3733; creation-date="Wed, 03 Mar 2021 17:31:38 GMT";
	modification-date="Wed, 03 Mar 2021 17:28:02 GMT"
Content-Transfer-Encoding: base64

Y29tbWl0IGVhMTcyMzA5MmQzNTZkYzRkMTI2Njk0MmFhMTMyMzQwNjc3ZTc0NjAKQXV0aG9yOiBE
b24gQnJhY2UgPGRicmFjZUByZWRoYXQuY29tPgpEYXRlOiAgIFdlZCBNYXIgMyAxMToyMTo1OSAy
MDIxIC0wNjAwCgogICAgaHBzYTogY29ycmVjdCBkZXYgY21kIG91dHN0YW5kaW5nIGZvciByZXRy
aWVkIGNtZHMKICAgIAogICAgUHJldmVudCBpbmNyZW1lbnRpbmcgZGV2aWNlLT5jb21tYW5kc19v
dXRzdGFuZGluZyBmb3IKICAgIHJldHJpZWQgY29tbWFuZHMuCgpkaWZmIC0tZ2l0IGEvZHJpdmVy
cy9zY3NpL2hwc2EuYyBiL2RyaXZlcnMvc2NzaS9ocHNhLmMKaW5kZXggZjRkMzc0N2NmYTBiLi40
M2M4ZjdlMjVlYjUgMTAwNjQ0Ci0tLSBhL2RyaXZlcnMvc2NzaS9ocHNhLmMKKysrIGIvZHJpdmVy
cy9zY3NpL2hwc2EuYwpAQCAtMTE1MSw3ICsxMTUxLDEwIEBAIHN0YXRpYyB2b2lkIF9fZW5xdWV1
ZV9jbWRfYW5kX3N0YXJ0X2lvKHN0cnVjdCBjdGxyX2luZm8gKmgsCiB7CiAJZGlhbF9kb3duX2xv
Y2t1cF9kZXRlY3Rpb25fZHVyaW5nX2Z3X2ZsYXNoKGgsIGMpOwogCWF0b21pY19pbmMoJmgtPmNv
bW1hbmRzX291dHN0YW5kaW5nKTsKLQlpZiAoYy0+ZGV2aWNlKQorCS8qCisJICogQ2hlY2sgdG8g
c2VlIGlmIHRoZSBjb21tYW5kIGlzIGJlaW5nIHJldHJpZWQuCisJICovCisJaWYgKGMtPmRldmlj
ZSAmJiAhYy0+cmV0cnlfcGVuZGluZykKIAkJYXRvbWljX2luYygmYy0+ZGV2aWNlLT5jb21tYW5k
c19vdXRzdGFuZGluZyk7CiAKIAlyZXBseV9xdWV1ZSA9IGgtPnJlcGx5X21hcFtyYXdfc21wX3By
b2Nlc3Nvcl9pZCgpXTsKQEAgLTU2MjMsNiArNTYyNiwxNiBAQCBzdGF0aWMgdm9pZCBocHNhX2Nv
bW1hbmRfcmVzdWJtaXRfd29ya2VyKHN0cnVjdCB3b3JrX3N0cnVjdCAqd29yaykKIAkJcmV0dXJu
IGhwc2FfY21kX2ZyZWVfYW5kX2RvbmUoYy0+aCwgYywgY21kKTsKIAl9CiAKKwkvKgorCSAqIFNN
TCByZXRyaWVzIGNvbWUgaW4gdGhyb3VnaCBxdWV1ZV9jb21tYW5kIGFuZCB0aGVyZWZvcmUKKwkg
KiBnbyB0aHJvdWdoIGNtZF90YWdnZWRfYWxsb2MuIFNvIGEgbmV3IGNvbW1hbmQuCisJICoKKwkg
KiBTZXQgYSByZXRyeV9wZW5kaW5nIGZsYWcgZm9yIGEgZHJpdmVyIGluaXRpYXRlZCByZXRyeSBh
dHRlbXB0CisJICogb24gYW4gZXhpc3RpbmcgY29tbWFuZCB0byBpbmRpY2F0ZSB0byBub3QgaW5j
cmVtZW50IHRoZQorCSAqIGRldmljZS0+Y29tbWFuZHNfb3V0c3RhbmRpbmcgd2hlbiBzdWJtaXR0
ZWQuCisJICovCisJYy0+cmV0cnlfcGVuZGluZyA9IDE7CisKIAlpZiAoYy0+Y21kX3R5cGUgPT0g
Q01EX0lPQUNDRUwyKSB7CiAJCXN0cnVjdCBjdGxyX2luZm8gKmggPSBjLT5oOwogCQlzdHJ1Y3Qg
aW9fYWNjZWwyX2NtZCAqYzIgPSAmaC0+aW9hY2NlbDJfY21kX3Bvb2xbYy0+Y21kaW5kZXhdOwpA
QCAtNTY0Niw2ICs1NjU5LDcgQEAgc3RhdGljIHZvaWQgaHBzYV9jb21tYW5kX3Jlc3VibWl0X3dv
cmtlcihzdHJ1Y3Qgd29ya19zdHJ1Y3QgKndvcmspCiAJCX0KIAl9CiAJaHBzYV9jbWRfcGFydGlh
bF9pbml0KGMtPmgsIGMtPmNtZGluZGV4LCBjKTsKKwogCWlmIChocHNhX2Npc3Nfc3VibWl0KGMt
PmgsIGMsIGNtZCwgZGV2KSkgewogCQkvKgogCQkgKiBJZiB3ZSBnZXQgaGVyZSwgaXQgbWVhbnMg
ZG1hIG1hcHBpbmcgZmFpbGVkLiBUcnkKQEAgLTU3MDgsNiArNTcyMiwxMCBAQCBzdGF0aWMgaW50
IGhwc2Ffc2NzaV9xdWV1ZV9jb21tYW5kKHN0cnVjdCBTY3NpX0hvc3QgKnNoLCBzdHJ1Y3Qgc2Nz
aV9jbW5kICpjbWQpCiAJLyoKIAkgKiBDYWxsIGFsdGVybmF0ZSBzdWJtaXQgcm91dGluZSBmb3Ig
SS9PIGFjY2VsZXJhdGVkIGNvbW1hbmRzLgogCSAqIFJldHJpZXMgYWx3YXlzIGdvIGRvd24gdGhl
IG5vcm1hbCBJL08gcGF0aC4KKwkgKiBOb3RlOiBJZiBjbWQtPnJldHJpZXMgaXMgbm9uLXplcm8s
IHRoZW4gdGhpcyBpcyBhIFNNTAorCSAqICAgICAgIGluaXRpYXRlZCByZXRyeSBhbmQgbm90IGEg
ZHJpdmVyIGluaXRpYXRlZCByZXRyeS4KKwkgKiAgICAgICBUaGlzIGNvbW1hbmQgaGFzIGJlZW4g
b2J0YWluZWQgZnJvbSBjbWRfdGFnZ2VkX2FsbG9jCisJICogICAgICAgYW5kIGlzIHRoZXJlZm9y
ZSBhIGJyYW5kLW5ldyBjb21tYW5kLgogCSAqLwogCWlmIChsaWtlbHkoY21kLT5yZXRyaWVzID09
IDAgJiYKIAkJCSFibGtfcnFfaXNfcGFzc3Rocm91Z2goY21kLT5yZXF1ZXN0KSAmJgpAQCAtNjEw
Nyw2ICs2MTI1LDcgQEAgc3RhdGljIGludCBocHNhX2VoX2RldmljZV9yZXNldF9oYW5kbGVyKHN0
cnVjdCBzY3NpX2NtbmQgKnNjc2ljbWQpCiAgKiBhdCBpbml0LCBhbmQgbWFuYWdlZCBieSBjbWRf
dGFnZ2VkX2FsbG9jKCkgYW5kIGNtZF90YWdnZWRfZnJlZSgpIHVzaW5nIHRoZQogICogYmxvY2sg
cmVxdWVzdCB0YWcgYXMgYW4gaW5kZXggaW50byBhIHRhYmxlIG9mIGVudHJpZXMuICBjbWRfdGFn
Z2VkX2ZyZWUoKSBpcwogICogdGhlIGNvbXBsZW1lbnQsIGFsdGhvdWdoIGNtZF9mcmVlKCkgbWF5
IGJlIGNhbGxlZCBpbnN0ZWFkLgorICogVGhpcyBmdW5jdGlvbiBpcyBvbmx5IGNhbGxlZCBmb3Ig
bmV3IHJlcXVlc3RzIGZyb20gcXVldWVfY29tbWFuZC4KICAqLwogc3RhdGljIHN0cnVjdCBDb21t
YW5kTGlzdCAqY21kX3RhZ2dlZF9hbGxvYyhzdHJ1Y3QgY3Rscl9pbmZvICpoLAogCQkJCQkgICAg
c3RydWN0IHNjc2lfY21uZCAqc2NtZCkKQEAgLTYxNDEsNiArNjE2MCwxMSBAQCBzdGF0aWMgc3Ry
dWN0IENvbW1hbmRMaXN0ICpjbWRfdGFnZ2VkX2FsbG9jKHN0cnVjdCBjdGxyX2luZm8gKmgsCiAJ
fQogCiAJYXRvbWljX2luYygmYy0+cmVmY291bnQpOworCS8qCisJICogVGhpcyBpcyBhIG5ldyBj
b21tYW5kIG9idGFpbmVkIGZyb20gcXVldWVfY29tbWFuZCBzbworCSAqIHRoZXJlIGhhdmUgbm90
IGJlZW4gYW55IGRyaXZlciBpbml0aWF0ZWQgcmV0cnkgYXR0ZW1wdHMuCisJICovCisJYy0+cmV0
cnlfcGVuZGluZyA9IDA7CiAKIAlocHNhX2NtZF9wYXJ0aWFsX2luaXQoaCwgaWR4LCBjKTsKIAly
ZXR1cm4gYzsKQEAgLTYyMTAsNiArNjIzNCwxMSBAQCBzdGF0aWMgc3RydWN0IENvbW1hbmRMaXN0
ICpjbWRfYWxsb2Moc3RydWN0IGN0bHJfaW5mbyAqaCkKIAl9CiAJaHBzYV9jbWRfcGFydGlhbF9p
bml0KGgsIGksIGMpOwogCWMtPmRldmljZSA9IE5VTEw7CisJLyoKKwkgKiBjbWRfYWxsb2MgaXMg
Zm9yICJpbnRlcm5hbCIgY29tbWFuZHMgYW5kIHRoZXkgYXJlIG5ldmVyCisJICogcmV0cmllZC4K
KwkgKi8KKwljLT5yZXRyeV9wZW5kaW5nID0gMDsKIAlyZXR1cm4gYzsKIH0KIApkaWZmIC0tZ2l0
IGEvZHJpdmVycy9zY3NpL2hwc2FfY21kLmggYi9kcml2ZXJzL3Njc2kvaHBzYV9jbWQuaAppbmRl
eCA0NmRmMmUzZmY4OWIuLmU4NmFmNGU5ZWVmMCAxMDA2NDQKLS0tIGEvZHJpdmVycy9zY3NpL2hw
c2FfY21kLmgKKysrIGIvZHJpdmVycy9zY3NpL2hwc2FfY21kLmgKQEAgLTQ0OCw3ICs0NDgsNyBA
QCBzdHJ1Y3QgQ29tbWFuZExpc3QgewogCSAqLwogCXN0cnVjdCBocHNhX3Njc2lfZGV2X3QgKnBo
eXNfZGlzazsKIAotCWludCBhYm9ydF9wZW5kaW5nOworCWludCByZXRyeV9wZW5kaW5nOwogCXN0
cnVjdCBocHNhX3Njc2lfZGV2X3QgKmRldmljZTsKIAlhdG9taWNfdCByZWZjb3VudDsgLyogTXVz
dCBiZSBsYXN0IHRvIGF2b2lkIG1lbXNldCBpbiBocHNhX2NtZF9pbml0KCkgKi8KIH0gX19hbGln
bmVkKENPTU1BTkRMSVNUX0FMSUdOTUVOVCk7Cg==

--_002_SN6PR11MB284885A5751845EEA290BFCFE1989SN6PR11MB2848namp_--
