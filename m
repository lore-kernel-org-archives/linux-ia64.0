From: Sam Ravnborg <sam@ravnborg.org>
Date: Sat, 08 Mar 2003 21:29:39 +0000
Subject: Re: [Linux-ia64] SN makefile stuff
Message-Id: <marc-linux-ia64-105590709806012@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805992@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805992@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, Mar 08, 2003 at 08:52:18AM -0800, Jesse Barnes wrote:
> > 2) take a good look in the corresponding makefile
> >   - Is the target included in EXTRA_TARGETS without $(obj)/ prefix?
> 
> Looks like this was the problem.  I think this is the final patch.

Great - and the patch (the parts I understands) look fine.

	Sam

