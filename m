From: "H. J. Lu" <hjl@lucon.org>
Date: Fri, 13 May 2005 14:10:23 +0000
Subject: Re: elf header bits for page migration support......
Message-Id: <20050513141023.GB24961@lucon.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <42847F6B.3080609@engr.sgi.com>
In-Reply-To: <42847F6B.3080609@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, May 13, 2005 at 05:20:27AM -0500, Ray Bryant wrote:
> Tony,
> 
> As some of the readers of this list may know, I've been working on a
> "manual page migration" facility for Altix.   Basically this is intended
> to allow a batch manager to move applications around on a large NUMA
> system.  Further details and discussion can be found on the linux-mm
> lists, for example the thread starting at:
> 
> http://marc.theaimsgroup.com/?l=linux-mm&m1578651020174&w=2
> 
> Now given the existence of the memory migration code in the memory
> hotplug patch, the hard part of this project is not doing the migration,
> but figuring out what not to migrate (e. g. one doesn't want to migrate
> the shared pages of a shared library, for example).  Currently, we are
> flagging files as libraries by using a file system extended attribute.
> But this is meeting with some resistance.
> 
> The alternative being suggested is to mark the elf header of object files
> that should only have shared pages migrated, or that should not be migrated
> (e. g. you don't want to migrate /bin/csh all the time.)
> 
> (We'll extend mmap() with a similar set of flags.)
> 
> So the question has come up, which bits in the elf header are available
> for such use.  Apparently there is a bit of a muddle here and we need to
> get the "community" to agree.

Bits in elf header are very scare. Can you use an ELF segment like
PT_GNU_EH_FRAME and PT_GNU_STACK?


H.J.
