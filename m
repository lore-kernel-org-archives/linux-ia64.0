From: Nathan Scott <nathans@sgi.com>
Date: Wed, 15 Oct 2003 06:16:23 +0000
Subject: Re: IA64 ino_t incorrectly sized?
Message-Id: <marc-linux-ia64-106619880520686@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106378281914262@msgid-missing>
In-Reply-To: <marc-linux-ia64-106378281914262@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Oct 14, 2003 at 06:48:07PM -0700, Andrew Morton wrote:
> Nathan Scott <nathans@sgi.com> wrote:
> >
> >  Anyway, here's the two patches (2.6 & 2.4).  The 2.4 version
> >  no longer applies cleanly to 2.6 due to other kernel changes,
> >  and the 2.6 kernel deprecates one of the 2.4 NFS structures.
> > 
> >  I'd appreciate any suggestions about a cleaner way to do the
> >  common types.h and nfsd/syscall.h header changes.
> 
> Can't think of anything clever really.
> 

One alternate approach would be to introduce __kernel_ustatino_t
and __kernel_nfsdino_t into every architecture's posix_types.h
(defining them as __kernel_ino_t everywhere but IA64, where they
would be unsigned int).  This would do away with any conditional
code in headers, but I'm not sure its the right approach at this
stage?

cheers.

-- 
Nathan
