From: Christoph Hellwig <hch@ns.caldera.de>
Date: Wed, 05 Sep 2001 20:47:17 +0000
Subject: Re: [Linux-ia64] Location of absolute IA32 shared objects.
Message-Id: <marc-linux-ia64-105590698805128@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805122@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805122@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Sep 05, 2001 at 02:53:11PM -0600, Don Dugger wrote:
> 2)  How do we deal with absolute path names in IA32 binaries?  This is
> the question I'm concerned with right now.  The sad reality of life is
> that there are rogue (I use the term `rogue' with tongue firmly planted
> in check) IA32 binaries that have hard coded absolute paths to certain
> libraries.  I think we all agree that `standard' libraries  must be IA64
> objects and, therefore, we need to find a way to deal with these
> rogue IA32 programs if we want them to run.
> 
> I have a proposed solution to 2 but it's not perfect.  I was kind of hoping
> that someone had a better idea but it doesn't look like it.  Unless someone
> comes up with a brainstorm I'll implement my idea and at least we should
> be able to run the rogue IA32 programs we know about.

Please take a look at include/asm-*/namei.h - we can define an emulation
prefix for Linux/i386 (e.g. /emul/linux32) and all lookups will be tried
there before falling back to the native FS,  This appropeach is already
used by the MIPS and SPARC ports and by linux-abi for i386.

	Christoph

-- 
Of course it doesn't work. We've performed a software upgrade.

