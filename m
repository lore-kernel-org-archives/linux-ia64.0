From: Jesse Barnes <jbarnes@sgi.com>
Date: Wed, 23 Oct 2002 20:49:35 +0000
Subject: Re: [Linux-ia64] ia64 compressed makefile target
Message-Id: <marc-linux-ia64-105590709805218@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805211@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805211@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Oct 23, 2002 at 12:01:29PM -0700, David Mosberger wrote:
> I don't have a strong preference either way, but I do have some
> concerns about the VMAP_KERNEL.  I really dislike the fact that it
> requires different versions of virtual-to-physical translations for
> kernel addresses.  No other platform does that, so it will be a source
> of continual worry.  Jesse, could you describe your approach a little
> more?  I assume you link the kernel with "ld -r" and have an elilo
> that applies the relocations?

Elilo 3.1 supports relocation, but now that I look, we're not passing -r
to ld when the kernel is linked, which makes me wonder why it works at
all.  But I've confirmed that a kernel stripped with --strip-all doesn't
boot, while the same binary stripped with --strip-debug does (haven't
tried --strip-unneeded, but that should work too).  I can look into it
more if you're not comfortable with the change, and maybe Tony has
something to add?

Thanks,
Jesse

