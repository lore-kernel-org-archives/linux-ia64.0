From: Stephane Eranian <eranian@hpl.hp.com>
Date: Wed, 26 Feb 2003 21:56:42 +0000
Subject: Re: [Linux-ia64] nfsroot on Linux/ia64
Message-Id: <marc-linux-ia64-105590709805935@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805932@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805932@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Dan,

On Wed, Feb 26, 2003 at 12:30:54PM -0800, MAGENHEIMER,DAN (HP-FtCollins,ex1) wrote:
> Has anyone tried using nfsroot (cf. "Documentation/nfsroot.txt")
> on Linux/ia64 to run "diskless"?  I expect that it will work fine
> but I need to do some testing where nfsroot may prove
> useful and hope to avoid investing a lot of energy if
> someone else has tried it and it, for some reason,
> doesn't work.
> 
Yes it does work I have used it in the past and it works
great with elilo. By diskless, I assume you mean that everything
comes from the network including elilo, vmlinuz and initrd.

If so I strongly suggest you take a look at the elilo documentation.
On a RHAS system this is /usr/share/doc/elilo-3.2/netbooting.txt. Go
to section 5/ Netbooting. There are examples of configurations.

-- 

-Stephane

