From: Sam Ravnborg <sam@ravnborg.org>
Date: Fri, 07 Mar 2003 07:02:45 +0000
Subject: Re: [Linux-ia64] SN makefile stuff
Message-Id: <marc-linux-ia64-105590709805997@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805992@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805992@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Mar 06, 2003 at 02:53:21PM -0800, Jesse Barnes wrote:

> > > +fakeprom: $(obj)/fakeprom $(obj)/vmlinux.sym
> > > +	cp $(obj)/fakeprom $(obj)/fprom
> > $(obj)/fprom is a target here.
> 
> I should probably just generate fprom directly instead of copying it,
> otherwise I should use $(src)/fprom?

Generating fakeprom is the preferred method.
Otherwise the above rule should look like this:
$(obj)/fakeprom: $(obj)/fprom $(obj)/vmlinux.sym
	cp $< $@


> > EXTRA_TARGETS := fprom fakeprom vmlinux.sym
> 
> Could that explain why the files in arch/ia64/sn/fakeprom get rebuilt
> everytime?

Missing the EXTRA_TARGETS may explain that.
That is used by kbuild to read the .fprom.cmd file - and to check if the
commandline changed. If it fails to read .fprom.cmd it obviously think
the commandline changed.

	Sam

