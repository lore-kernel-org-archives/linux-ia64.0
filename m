From: Jesse Barnes <jbarnes@sgi.com>
Date: Tue, 11 Mar 2003 23:08:19 +0000
Subject: Re: [Linux-ia64] [PATCH] SN makefile update
Message-Id: <marc-linux-ia64-105590709806040@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806013@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806013@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 11, 2003 at 02:55:14PM -0800, David Mosberger wrote:
>   Jesse> Thanks again for taking a look at this.  David, can you apply
>   Jesse> this?
> 
> Most of it looks fine to me.  However, is the fprom stuff ever going
> to be useful to anyone other than SGI users?  If not, I'd prefer if
> we could put that stuff in an SGI-specific Makefile.

Probably not, but I don't know how to put a makefile target like that
in arch/ia64/sn/Makefile.  Sam, is there a way to do this?

Thanks,
Jesse

