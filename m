From: Arnd Bergmann <arnd@kernel.org>
Date: Tue, 30 Mar 2021 07:34:00 +0000
Subject: Re: [PATCH v2 3/3] hpsa: add an assert to prevent from __packed reintroduction
Message-Id: <CAK8P3a2CmQpKynwGbtdWH+1L4=SkX2y4XKggT=8DrnsjxU4hSw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1wntpgxxr.fsf@ca-mkp.ca.oracle.com> <20210330071958.3788214-1-slyfox@gentoo.org>
 <20210330071958.3788214-3-slyfox@gentoo.org>
In-Reply-To: <20210330071958.3788214-3-slyfox@gentoo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergei Trofimovich <slyfox@gentoo.org>
Cc: "Martin K. Petersen" <martin.petersen@oracle.com>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, Don Brace <don.brace@microchip.com>, linux-ia64@vger.kernel.org, storagedev@microchip.com, linux-scsi <linux-scsi@vger.kernel.org>, jszczype@redhat.com, Scott Benesh <scott.benesh@microchip.com>, Scott Teel <scott.teel@microchip.com>, thenzl@redhat.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Mar 30, 2021 at 9:23 AM Sergei Trofimovich <slyfox@gentoo.org> wrote:

> +/*
> + * Make sure our embedded atomic variable is aligned. Otherwise we break atomic
> + * operations on architectures that don't support unaligned atomics like IA64.
> + *
> + * The assert guards against reintroductin against unwanted __packed to
> + * the struct CommandList.
> + */
> +static_assert(offsetof(struct CommandList, refcount) % __alignof__(atomic_t) = 0);
> +

There are a few other members that need to be aligned: the work_struct
has another
atomic_t inside it, and there are a few pointers that might rely on
being written to
atomically.

While you could add a static_assert for each member, the easier solution is to
just not ask for the members to be misaligned in the first place.

       Arnd
