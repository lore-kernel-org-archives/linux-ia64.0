From: Grant Grundler <grundler@cup.hp.com>
Date: Sat, 06 Apr 2002 01:12:04 +0000
Subject: Re: [Linux-ia64] Re: Boot hangs "Probing PCI hardware"
Message-Id: <marc-linux-ia64-105590701905400@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905390@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905390@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

=?iso-2022-jp?B?IhskQkRhQG4hIUMjTGkbKEIi?= wrote:
...
> In this case, the video device gets 64MB memory space from 0xFC000000 to
> 0xFFFFFFFF improperly, and it conflicts with System reserve region
> (0xFCxxxxxx - 0xFExxxxxx) for SAPIC interrupt messages. After that
> the video device reacts to an SAPIC interrupt improperly.

Martin, et al,
I also believe this is a problem.
I just haven't seen it because I'm always using serial console.

This problem might also exist on x86 Foster CPU as well.
The new x86 CPU also uses IO-xAPIC and Local xAPIC.
I don't have access to a physical memory map of such a box
to confirm it though.

I don't believe this is a problem on HP parisc (also uses
IO-SAPIC) because of how PCI address routing works.

grant

