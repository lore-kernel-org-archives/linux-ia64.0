From: "Matt D. Robinson" <yakker@alacritech.com>
Date: Fri, 06 Oct 2000 17:51:15 +0000
Subject: Re: [Linux-ia64] Taking a dump while kernel panic]
Message-Id: <marc-linux-ia64-105590678205554@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205552@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205552@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Steve Neuner wrote:
> 
> Did you see this?  You might want to sync up with them.
> 
> --steve
> 
> -------- Original Message --------
> Subject: Re: [Linux-ia64] Taking a dump while kernel panic
> Date: Fri, 06 Oct 2000 13:13:16 -0400
> From: "Pat O'Rourke" <orourke@mclinux.com>
> To: Bruno Vidal <bruno_vidal@hpfrcu03.france.hp.com>
> CC: linux-ia64@linuxia64.org
> 
> > I'm looking for something to take a dump when system panic.
> > I've found the patch from SGI to do that. But I'm asking if
> > there is something to take a dump in the IA64 project ?
> 
> We (Mission Critical Linux) have a kernel patch which creates a
> core dump on panic and also a tool (crash) which can be used to
> analyze the resulting dump.  We're in the process of porting the
> core dump patch to ia64; the crash tool has been ported to ia64
> already.
> 
> Pat

We have some code that will do the dump on IA64 systems, so long
as you aren't using 64K page sizes.  If you'd like a patch for
this, let me know.  Note that this is against 2.4, not 2.3.99-preXX,
which is significant since some of the trace functionality had to
change.

--Matt

