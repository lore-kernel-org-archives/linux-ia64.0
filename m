From: Sam Ravnborg <sam@ravnborg.org>
Date: Sat, 08 Mar 2003 09:56:24 +0000
Subject: Re: [Linux-ia64] SN makefile stuff
Message-Id: <marc-linux-ia64-105590709806010@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805992@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805992@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Mar 07, 2003 at 05:13:41PM -0800, Jesse Barnes wrote:
> Does this look a little better?  Still can't figure out why fprom
> always rebuilds all files though...

What is included in the patch looks fine.
But you did not include arch/ia64/sn/fakeprom/Makefile this time??

To catch the reason why fprom rebuilds all (not all, but some I guess)
files follow these steps.

1) What file is the first being rebuild
- When one file is being rebuild obviously all files dependent on
  this one will be rebuild.
2) take a good look in the corresponding makefile
  - Is the target included in EXTRA_TARGETS without $(obj)/ prefix?
  - Is FORCE one of the prerequisites to the target?
    - Thats needed if you use $(call if_changed,{gzip,ld,objcopy}
3) Did you use a space in the $(call if_changed, ld)
                                                ^
$(call if_changed,ld)  <= correct
$(call if_changed, ld) <= wrong

4) ... Lots of other reasons. Send me the makefile in question off-line
   if you want an extra pair of eyes on it.

One unrelated question.
Would it be possible to use the mach- scheme as used for i386 for sn?
As it is done today it looks like a new architecture hidden
below arch/ia64/*.

	Sam

