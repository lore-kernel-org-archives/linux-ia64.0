From: Grant Grundler <iod00d@hp.com>
Date: Tue, 04 May 2004 17:19:58 +0000
Subject: Re: mmap() of /dev/kmem issue
Message-Id: <20040504171958.GF1701@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4097C51D.71EA0BEA@email.mot.com>
In-Reply-To: <4097C51D.71EA0BEA@email.mot.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, May 04, 2004 at 11:30:21AM -0500, Mario Smarduch wrote:
> I have problem of viewing memory contents via mmap() of /dev/kmem.

1) which regions/addresses are you accessing?
2) what values do you see/should see?
3) test case?

grant

> After mmap()'ing /dev/kmem for reading
> it appears that data accessed in the kernel lives in
> different cache lines from data accessed in the user space.
> The lseek()/read() from kernel reflects latest updates,
> but same reads from user space mmap fetches old data, and
> vice versa when updating from user. When I flush the
> caches (cat of a big file to another file), then user mapped
> value reflects the latest changes but then again remains
> frozen. I'm having trouble understanding how can this
> happen since the caches are physically indexed.
> Any ideas what the problem could be?
> 
> - Mario.
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
