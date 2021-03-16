From: Arnd Bergmann <arnd@kernel.org>
Date: Tue, 16 Mar 2021 18:28:22 +0000
Subject: Re: [PATCH] hpsa: fix boot on ia64 (atomic_t alignment)
Message-Id: <CAK8P3a3JYmhbN3TXB2cWGfXGKgsUa9Hg=ZvWckTaL_31OMgbtQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5532f9ab-7555-d51b-f4d5-f9b72a61f248@redhat.com>
 <20210312222718.4117508-1-slyfox@gentoo.org> <SN6PR11MB2848561E3D85A8F55EB86977E16B9@SN6PR11MB2848.namprd11.prod.outlook.com>
In-Reply-To: <SN6PR11MB2848561E3D85A8F55EB86977E16B9@SN6PR11MB2848.namprd11.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Don.Brace@microchip.com
Cc: Sergei Trofimovich <slyfox@gentoo.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, storagedev@microchip.com, linux-scsi <linux-scsi@vger.kernel.org>, jszczype@redhat.com, Scott.Benesh@microchip.com, Scott.Teel@microchip.com, thenzl@redhat.com, "Martin K. Petersen" <martin.petersen@oracle.com>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>

On Tue, Mar 16, 2021 at 6:12 PM <Don.Brace@microchip.com> wrote:

>  drivers/scsi/hpsa_cmd.h | 14 +++++++++++++-
>  1 file changed, 13 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/scsi/hpsa_cmd.h b/drivers/scsi/hpsa_cmd.h index d126bb877250..617bdae9a7de 100644
> --- a/drivers/scsi/hpsa_cmd.h
> +++ b/drivers/scsi/hpsa_cmd.h
> @@ -20,6 +20,9 @@
>  #ifndef HPSA_CMD_H
>  #define HPSA_CMD_H
>
> +#include <linux/build_bug.h> /* static_assert */ #include
> +<linux/stddef.h> /* offsetof */
> +
>  /* general boundary defintions */
>  #define SENSEINFOBYTES          32 /* may vary between hbas */
>  #define SG_ENTRIES_IN_CMD      32 /* Max SG entries excluding chain blocks */
> @@ -448,11 +451,20 @@ struct CommandList {
>          */
>         struct hpsa_scsi_dev_t *phys_disk;
>
> -       bool retry_pending;
> +       int retry_pending;
>         struct hpsa_scsi_dev_t *device;
>         atomic_t refcount; /* Must be last to avoid memset in hpsa_cmd_init() */  } __aligned(COMMANDLIST_ALIGNMENT);
>
> +/*
> + * Make sure our embedded atomic variable is aligned. Otherwise we
> +break atomic
> + * operations on architectures that don't support unaligned atomics like IA64.
> + *
> + * Ideally this header should be cleaned up to only mark individual
> +structs as
> + * packed.
> + */
> +static_assert(offsetof(struct CommandList, refcount) %
> +__alignof__(atomic_t) = 0);
> +

Actually that still feels wrong: the annotation of the struct is to pack
every member, which causes the access to be done in byte units
on architectures that do not have hardware unaligned load/store
instructions, at least for things like atomic_read() that does not
go through a cmpxchg() or ll/sc cycle.

This change may fix itanium, but it's still not correct. Other
architectures would have already been broken before the recent
change, but that's not a reason against fixing them now.

I'd recommend marking the entire structure as having default
alignment, by adding the appropriate pragmas before and after it.

         Arnd
