From: Arnd Bergmann <arnd@kernel.org>
Date: Tue, 30 Mar 2021 07:30:44 +0000
Subject: Re: [PATCH v2 1/3] hpsa: use __packed on individual structs, not header-wide
Message-Id: <CAK8P3a32frskYgoXi2ncOcLfhqcMDssSBp79p7WSRg3VPhmSdA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1wntpgxxr.fsf@ca-mkp.ca.oracle.com> <20210330071958.3788214-1-slyfox@gentoo.org>
In-Reply-To: <20210330071958.3788214-1-slyfox@gentoo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergei Trofimovich <slyfox@gentoo.org>
Cc: "Martin K. Petersen" <martin.petersen@oracle.com>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, Don Brace <don.brace@microchip.com>, linux-ia64@vger.kernel.org, storagedev@microchip.com, linux-scsi <linux-scsi@vger.kernel.org>, jszczype@redhat.com, Scott Benesh <scott.benesh@microchip.com>, Scott Teel <scott.teel@microchip.com>, thenzl@redhat.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Mar 30, 2021 at 9:22 AM Sergei Trofimovich <slyfox@gentoo.org> wrote:
>
> Some of the structs contain `atomic_t` values and are not intended to be
> sent to IO controller as is.
>
> The change adds __packed to every struct and union in the file.
> Follow-up commits will fix `atomic_t` problems.
>
> The commit is a no-op at least on ia64:
>     $ diff -u <(objdump -d -r old.o) <(objdump -d -r new.o)

This looks better to me, but I think it still has the same potential bug in
the CommandList definition. Moving from #pragma to annotating the
misaligned structures as __packed is more of a cleanup that could
be done separately from the bugfix, but it does make it a little more
robust.

>  #define HPSA_INQUIRY 0x12
>  struct InquiryData {
>         u8 data_byte[36];
> -};
> +} __packed;

Marking this one and a few others as __packed is a bit silly, but
also obviously harmless, and closer to the original version, so that's
ok.

> @@ -451,7 +452,7 @@ struct CommandList {
>         bool retry_pending;
>         struct hpsa_scsi_dev_t *device;
>         atomic_t refcount; /* Must be last to avoid memset in hpsa_cmd_init() */
> -} __aligned(COMMANDLIST_ALIGNMENT);
> +} __packed __aligned(COMMANDLIST_ALIGNMENT);

You are still marking CommandList as __packed here, which is
what caused the original problem. Please don't mark this one
as __packed at all. If there are individual members that you want
to be misaligned inside of the structure, you could mark those
explicitly.

      Arnd
