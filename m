From: Jesse Barnes <jbarnes@sgi.com>
Date: Wed, 23 Oct 2002 15:47:25 +0000
Subject: Re: [Linux-ia64] ia64 compressed makefile target
Message-Id: <marc-linux-ia64-105590709805213@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805211@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805211@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Oct 23, 2002 at 11:26:27AM +0200, Andreas Schwab wrote:
> Jesse Barnes <jbarnes@sgi.com> writes:
> 
> |> David and Bjorn,
> |> 
> |> I noticed that the arch/ia64/Makefile 'compressed' target there's a
> |> '--strip-all' arg getting passed to objcopy.  This has the effect of
> |> removing relocation info from the vmlinux binary that we need for
> |> systems w/o memory at the default link address, if I understand
> |> correctly.  Would it be possible to change this option to
> |> '--strip-debug' instead?
> 
> How about --strip-unneeded?
> 
> Andreas.

Even better.

Thanks,
Jesse

