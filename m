From: Jesse Barnes <jbarnes@sgi.com>
Date: Thu, 08 May 2003 00:04:09 +0000
Subject: Re: [Linux-ia64] Re: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705663@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, May 07, 2003 at 04:51:21PM -0700, David Mosberger wrote:
> How many tools are out there that depend on System.map or similar?  I
> suppose you could just generate a fresh System.map at boot time (or
> have something like /proc/System.map).

Forgot to mention that there are tools that depend on this (e.g.
VTune, but it only cares about the load addr and size), but
/proc/ksyms may be enough already if the right symbols are exported.
Is it still there in 2.5?

Thanks,
Jesse

