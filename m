From: Keiichiro Tokunaga <tokunaga.keiich@jp.fujitsu.com>
Date: Thu, 13 May 2004 06:35:24 +0000
Subject: Re: Who's doing what with cpu/memory/node hotplug?
Message-Id: <20040513153524.79f90589.tokunaga.keiich@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040512205107.16bb82a6.pj@sgi.com>
In-Reply-To: <20040512205107.16bb82a6.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ashok Raj has already talked about LHNS and me :)  However,
I'd like to add something.

> Node Hotplug support - Tokunaga-san (fujitsu) mostly concentrating on 
> 		ACPI based numa node hotplug. This work is independent
> of rest of the hotplug (atleast mostly) and would invoke other module
> hotplug code as required.  (roughly @10000 ft level)

I'm rather focusing on ACPI based container device hotplug.
A scope of LHNS includes a container device that contains
IO devices.  I think such a devices couldn't be handled by NUMA
hotplug.

Thanks,
Kei


On Wed, 12 May 2004 20:51:07 -0700
Paul Jackson <pj@sgi.com> wrote:

> Could someone explain to me who's doing what with cpu, memory and node hotplug?
> 
> In particular, I haven't noticed much interaction between some cpu
> hotplug work that Ashok has been posting on linux-ia64 and/or lkml, and
> either of the email lists lhns-devel or linux-hotplug-devel.  And I also
> just noticed the thread on lkml by Keiichiro, with comments from Dave,
> mentioning Matthew, hinting at additional interactions that might be
> desirable between various efforts here.  I even see some SGI work here.
> 
> Perhaps if I had been following this for a while, it would all make sense.
> But I haven't been, and it doesn't.
> 
> -- 
>                           I won't rest till it's the best ...
>                           Programmer, Linux Scalability
>                           Paul Jackson <pj@sgi.com> 1.650.933.1373
