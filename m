From: Sam Ravnborg <sam@ravnborg.org>
Date: Wed, 12 Mar 2003 19:46:04 +0000
Subject: Re: [Linux-ia64] [PATCH] SN makefile update
Message-Id: <marc-linux-ia64-105590709806069@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806013@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806013@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 11, 2003 at 03:08:19PM -0800, Jesse Barnes wrote:
> > 
> > Most of it looks fine to me.  However, is the fprom stuff ever going
> > to be useful to anyone other than SGI users?  If not, I'd prefer if
> > we could put that stuff in an SGI-specific Makefile.
> 
> Probably not, but I don't know how to put a makefile target like that
> in arch/ia64/sn/Makefile.  Sam, is there a way to do this?

The best proposal I can come up with right now is to accept the
following command:
make arch/ia64/sn/fprom/ fprom

That should do the trick, if you go back to a fprom target without path.

So arch/ia64/sn/fprom/Makefile looks something like this:
.PHONY: fakeprom
fakeprom: $(obj)/fakeprom
	command to create fprom

Then you may add the whle fakeprom directory only on internal SGI kernels.
Or you could have a special Makefile for SGI.

Looks OK?

	Sam

