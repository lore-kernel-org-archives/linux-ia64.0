From: Keith Owens <kaos@ocs.com.au>
Date: Wed, 28 Aug 2002 19:11:30 +0000
Subject: Re: [Linux-ia64] make xconfig
Message-Id: <marc-linux-ia64-105590701905997@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905993@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905993@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 28 Aug 2002 09:02:16 -0700 (PDT), 
Jason Baron <almostivan@yahoo.com> wrote:
>If I enable xconfig, I get these errors from the 
>linux-2.4.19-ia64-020821.diff:
>
>ERROR - Attempting to write value for unconfigured
>variable (CONFIG_BLK_DEV_LOOP).
>ERROR - Attempting to write value for unconfigured
>variable (CONFIG_BLK_DEV_NBD).
>ERROR - Attempting to write value for unconfigured
>variable (CONFIG_BLK_DEV_RAM).
>
>The consequence is that these parameters do not get
>written to the appropriate files.  Also, there are two
>top level "Block devices" menues.
>
>This issue has been discussed a bit and I agree that
>the right solution is probably to fix the way that
>xconfig works.

It is an undocumented restriction of xconfig that an option should only
be set in one menu.  xconfig can detect sets of options within a menu,
it sometimes detects sets of options across menus but do not rely on
that.  Nobody who has looked at the xconfig code is willing to remove
this restriction (they usually turn white and and run away).

Unfortunately some architectures break this rule and break xconfig.

>Short of this, we could choose not to
>source drivers/block/Config.in, and instead include
>the drivers/block/Config.in parameters in
>arch/ia64/config.in, as in the attached patch.  This
>bloats the file a bit, but solves the issue in an arch
>independent way.

Given the current menuconfig and xconfig code, the only workable fix is
to follow the config rules.  That means any variable should only be set
in one menu.  Do not duplicate variables in arch/ia64/config.in.
Instead add conditions around the variables in drivers/block/Config.in
and other Config.in files.

I sent DM a patch to do just this, but he rejected it.  Instead xconfig
was disabled.  Disabling xconfig is not the solution, multiple
definitions of a variable in multiple menus will silently break
menuconfig as well (think out of order menu selection).


