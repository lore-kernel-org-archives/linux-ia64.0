From: Greg Banks <gnb@melbourne.sgi.com>
Date: Wed, 05 Nov 2003 04:11:46 +0000
Subject: Re: [RFC] Better MCA recovery on IPF
Message-Id: <marc-linux-ia64-106800571229818@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106724227826901@msgid-missing>
In-Reply-To: <marc-linux-ia64-106724227826901@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith Owens wrote:
> 
> On Sat, 1 Nov 2003 07:39:52 +0100 ("CET),
> Matthias Fouquet-Lapar <mfl@sgi.com> wrote:
> >I think there should be an abstraction layer hiding the underlying
> >HW implementation. I think handling for example a memory error
> >by killing the affected user application, should work on any chipset
> >and/or CPU architecture (if technically possible).
> 
> We already have that interface, it is called a signal.  The kernel code
> for handling these events has to be architecture dependent but, once
> the data has been gathered and the decision made about which user
> process to kill, we just send SEGV.

The problem with SEGV is that there exist applications which do
strange mmap/mprot tricks and catch and retry SEGVs to implement
app-level paging-like behaviour.  Two examples which already
run on (some ports of) Linux are:

The Texas Persistent Store (open source)
http://www.iam.unibe.ch/~scg/Archive/Software/FreeDB/FreeDB.23.html

ObjectStore (commercial)
http://www.objectstore.net/products/objectstore/index.ssp

You'd have to use SIGBUS or some other signal, or add a new code
to the sigcontext to allow those apps to handle the difference.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.
