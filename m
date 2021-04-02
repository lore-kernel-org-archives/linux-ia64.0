From: "Martin K. Petersen" <martin.petersen@oracle.com>
Date: Fri, 02 Apr 2021 03:54:48 +0000
Subject: Re: [PATCH v2 1/3] hpsa: use __packed on individual structs, not header-wide
Message-Id: <161733538518.31379.13275738935787597303.b4-ty@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1wntpgxxr.fsf@ca-mkp.ca.oracle.com> <20210330071958.3788214-1-slyfox@gentoo.org>
In-Reply-To: <20210330071958.3788214-1-slyfox@gentoo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Scott Teel <scott.teel@microchip.com>, jszczype@redhat.com, storagedev@microchip.com, Don Brace <don.brace@microchip.com>, Sergei Trofimovich <slyfox@gentoo.org>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, Arnd Bergmann <arnd@kernel.org>, Scott Benesh <scott.benesh@microchip.com>, thenzl@redhat.com, linux-ia64@vger.kernel.org, linux-scsi <linux-scsi@vger.kernel.org>
Cc: "Martin K . Petersen" <martin.petersen@oracle.com>, linux-kernel@vger.kernel.org

On Tue, 30 Mar 2021 08:19:56 +0100, Sergei Trofimovich wrote:

> Some of the structs contain `atomic_t` values and are not intended to be
> sent to IO controller as is.
> 
> The change adds __packed to every struct and union in the file.
> Follow-up commits will fix `atomic_t` problems.
> 
> The commit is a no-op at least on ia64:
>     $ diff -u <(objdump -d -r old.o) <(objdump -d -r new.o)

Applied to 5.12/scsi-fixes, thanks!

[1/3] hpsa: use __packed on individual structs, not header-wide
      https://git.kernel.org/mkp/scsi/c/5482a9a1a8fd
[2/3] hpsa: fix boot on ia64 (atomic_t alignment)
      https://git.kernel.org/mkp/scsi/c/02ec144292bc
[3/3] hpsa: add an assert to prevent from __packed reintroduction
      https://git.kernel.org/mkp/scsi/c/e01a00ff62ad

-- 
Martin K. Petersen	Oracle Linux Engineering
