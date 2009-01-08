From: Steven Rostedt <srostedt@redhat.com>
Date: Thu, 08 Jan 2009 17:08:07 +0000
Subject: RE: [PATCH 5/5] IA64 dynamic ftrace support
Message-Id: <1231434487.21980.5.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1230012500.10933.102.camel@sli10-desk.sh.intel.com>
In-Reply-To: <1230012500.10933.102.camel@sli10-desk.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Thu, 2009-01-08 at 16:05 +0800, Shaohua Li wrote:
> On Tue, 2009-01-06 at 08:42 +0800, Luck, Tony wrote:
> > > In this way, only one instruction is changed to convert code between nop
> > > and call. This should meet dyn-ftrace's requirement.
> > > But this requires CPU support brl instruction, so dyn-ftrace isn't
> > > supported for old Itanium system. Assume there are quite few such old
> > > system running.
> > 
> > Perhaps very few old Merced systems are used for development
> > and performance tuning (the kind of work where ftrace is useful).
> > So not having ftrace support on them might not be too big a loss.
> Tony,
> I simplified the patch to make it more clean, no functional change with
> the one I sent last week. please give it a try and consider merge if
> possible.

> Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> ---
>  arch/ia64/Kconfig              |    2 
>  arch/ia64/include/asm/ftrace.h |   13 ++
>  arch/ia64/kernel/Makefile      |    5 
>  arch/ia64/kernel/entry.S       |   51 ++++++++++
>  arch/ia64/kernel/ftrace.c      |  206 +++++++++++++++++++++++++++++++++++++++++
>  scripts/recordmcount.pl        |    7 +

Shaohua,

Are you changes now confined to ia64 (besides the recordmcount.pl)
change?  Any changes to the ftrace infrastructure we would like to go
through tip. This will give it proper testing against all archs before
pushing it to mainline.

Please send me any patches outside of arch/ia64 that we can pull in.
This includes the recordmcount.pl patch.

Also, send it to rostedt@goodmis.org that account has my scripts to pull
into git.

Thanks,

-- Steve




