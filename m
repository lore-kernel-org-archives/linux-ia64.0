From: Richard Hirst <rhirst@linuxcare.com>
Date: Wed, 27 Jun 2001 17:24:18 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.5)
Message-Id: <marc-linux-ia64-105590693005785@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jun 27, 2001 at 12:09:08AM -0700, David Mosberger wrote:
> The latest IA-64 patch is available at:
> 
>  ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/
> 
> in file linux-2.4.5-ia64-010626.diff*.

I appled that to a Linus 2.4.5 tree, but it doesn't compile with
devfs enabled but dev/guid disabled.  fs/partitions/check.c:522
has an unprotected call to free_disk_guids().

Richard


