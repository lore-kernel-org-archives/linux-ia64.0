From: Jes Sorensen <jes@sgi.com>
Date: Mon, 03 Sep 2007 09:21:41 +0000
Subject: Re: [PATCH 1/1] Allow global purge traslation cache (ptc.g) to be disabled
Message-Id: <yq03axwf6je.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <200708301338.34246.protasnb@gmail.com>
In-Reply-To: <200708301338.34246.protasnb@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Natalie" = Natalie Protasevich <protasnb@gmail.com> writes:

Natalie> From: Natalie Protasevich <protasnb@gmail.com>

Natalie> This patch allows to disable ptc.g. The code used to be in
Natalie> the kernel, then was removed in 2.4 since the bug that it was
Natalie> fixing has gone away. However, some large system vendors now
Natalie> want this capability available through a means that can be
Natalie> controlled by the platform in the event that there is an
Natalie> issue with either processor or their chipset where global
Natalie> ptc.g is not operational.  They want the mechanism for future
Natalie> platforms to work around such issues. It is also needed for
Natalie> platform makers when they deliberately do not use the global
Natalie> cache purge in their chipset implementation. (For such cases,
Natalie> Intel provided a SAL table entry to specify if ptc.g is
Natalie> allowed and how many).

If you need a special TLB purge implementation, please use the machine
vector as we do on the sn2 architecture - there is no reason to
implement a boot time option for this.

Who are these large system vendors who want this patch in? I presume
it's not the people running gmail? :-)

Cheers,
Jes
