From: Grant Grundler <iod00d@hp.com>
Date: Wed, 14 May 2003 06:33:33 +0000
Subject: Re: [Linux-ia64] Dump driver module
Message-Id: <marc-linux-ia64-105590723705778@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705751@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705751@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, May 14, 2003 at 12:32:17PM +1000, Martin Pool wrote:
> But you also need to know which disk to write to, and where.
...
> If any of this got screwed up, you might
> write your dump over /home instead -- and then rather than a possibly
> once-off kernel crash, you've lost lots of data.

I'll take that risk since I've never seen it nor heard of it
happening with HPUX after ~6 years of working HPUX IO subsystems.
I'm sure HPUX has done things to help mitigate that risk.
(like storing paths in NVRAM or some other hard to reach place.)
All problem reports (including memory corruption problems) came with
crash dumps.

Besides, fsck after the reboot is much more likely to trash data
on disk than the original memory corruption problem.

While it's clearly feasible to dump over gigabit networks,
I'm not sure how pervasive gigabit networks are.
Probably standard now for core commercial/scientific centers.
I fear dumping 4GB of memory over 100BT would be painful.
(I pulled 4GB out of a hat; rx5670 supports 48GB of RAM).

grant

