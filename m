From: Don Dugger <n0ano@n0ano.com>
Date: Fri, 15 Nov 2002 02:25:33 +0000
Subject: Re: [Linux-ia64] One little, two little, three little endian...
Message-Id: <marc-linux-ia64-105590709805444@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805439@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805439@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

My reaction is why?

If the HP-UX people are converting to Linux you're talking about porting
the applications anyway.  Why don't you just bite the bullet and port
the applications to little endian Linux and be done with it.  I know
there's a tendency to shudder when contemplating an endian port but it's
really not that difficult these days.  GCC is pretty good about flagging
most of the issues that get you in trouble so if you resolve all warnings
carefully most of the job is done.  It's actually easier to port from
big endian to little than vice versa so you'd be faced with the simpler
problem.

If the apps have assembly language it's going to be a complete port
anyway so porting to little endian doesn't add any work there.

Data compatibility is the only real gotcha I can think of and that's just
a translation issue.  Potentially creating the translation utilities will
be a problem but I predict it's a smaller problem than coming up with a
big endian IA64 Linux.

On Thu, Nov 14, 2002 at 04:52:13PM -0800, Gavin Scott wrote:
> Hello list,
> 
> I want a big endian version of Linux for IPF.  Just how crazy am I?
> 
> I'm working with a group of customers and software developers who are
> migrating away from HP's proprietary MPE/iX operating system on the HPe3000
> systems that HP announced the discontinuance of one year ago today.  Many of
> these people are already using HP-UX to some degree, and most are interested
> in the possibility of using Linux in the future.
> 
> Of course both MPE/iX and HP-UX are big-endian environments, and many of the
> people I talk to would be very interested in having an endian-compatible
> Linux that would run on big (i.e. IA-64) HP servers.  For this group, x86
> compatibility is probably a non-issue.
> 
> I'm interested in any comments that come to mind.  I'm most interested in
> just how complex the task would be from a technical point of view, either to
> make the system buildable either way, or possibly supporting a per-process
> endian bit (which would be cool, but probably a lot more work).
> 
> I'm reasonably familiar with the IA-64 architecture and know most of what
> there is to know about PA-RISC.
> 
> Thanks,
> 
> Gavin
> --
> Gavin Scott
> Vice President
> Allegro Consultants, Inc.
> gavin@allegro.com
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@n0ano.com

