From: Steven Rostedt <rostedt@goodmis.org>
Date: Fri, 09 Jan 2009 02:51:13 +0000
Subject: Re: [PATCH 0/6]IA64 ftrace port
Message-Id: <alpine.DEB.1.10.0901082146310.18713@gandalf.stny.rr.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1231468364.10683.99.camel@sli10-desk.sh.intel.com>
In-Reply-To: <1231468364.10683.99.camel@sli10-desk.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Fri, 9 Jan 2009, Shaohua Li wrote:

> This series are the ia64 ftrace porting. The patches hasn't functional
> changes against my repvious post. I just split them for merge. Patches
> are against latest -tip tree.
> 
> Steve,
> the first 4 patches are preparation patch and not in IA64 arch.
> the last two are IA64 specific.

Thanks, Just a quick note on change logs and subject lines.

The following is needed, in the subject have the subsystem name included.

ie.

	Subject: [PATCH] ia64, ftrace: ia64 ftrace port

If it is just one subsystem you only need:

	Subject: [PATCH] ia64: ...

But since this also has to deal with ftrace, do the former instead.

Also, we've been starting to add Impact lines to the change log. But I'm 
not too picky on that.

But, please do not lightly reference another patch in the log of a 
patch. Each change log needs to stand on its own, if someone does a
"git blame" and looks at the log, they will get quite upset if they see 
something like:

	This is needed for the same reason as the previous patch.

Thanks,

-- Steve

