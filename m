From: Nathan Straz <nstraz@sgi.com>
Date: Tue, 16 Oct 2001 15:44:58 +0000
Subject: Re: [Linux-ia64] lost printk's
Message-Id: <marc-linux-ia64-105590698805352@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805347@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805347@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Oct 16, 2001 at 08:37:05AM -0700, Randolph Chung wrote:
> > Can anyone recommend a console server that works well with Itanium
> > machines?  The problem with most console servers (or inversely EFI) is
> > that they don't run at 115200 baud.  Is everyone just running a line to
> > another PC?  Is there a console server that can handle several of these
> > machines?
> 
> EFI does work at 115200 -- i use that here in my setup; but I only
> have it hooked up to a PC.

Maybe I should clarify that.

Most console servers (that I've run across) don't run at 115200.
EFI _only_ runs at 115200. :(

-- 
Nate Straz                                              nstraz@sgi.com
sgi, inc                                           http://www.sgi.com/
Linux Test Project                                  http://ltp.sf.net/

