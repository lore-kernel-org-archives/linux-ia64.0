From: Ray Bryant <raybry@engr.sgi.com>
Date: Tue, 10 Dec 2002 22:11:24 +0000
Subject: [Linux-ia64] a couple questions on pfmon-2.0
Message-Id: <marc-linux-ia64-105590709805539@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Stephane,

There are both 2.0 and 2.0-1 versions mentioned in your note.  Are these
versions signifcantly different?? which one should we be using?

WRT documentation -- this is great, much improved.  One question I still
had is the following:  If I fork a child process, after calling
pfm_initialize(), and, assuming we bind threads to processors in some
fashion, do I need to call pfm_initialize() again in the child thread? 
What if the child thread is created by pthread_create()?

My experience with this is that most routines have to be called on the
thread (e. g. things that get or set PMU regs have to be called in the
appropriate child process, whilst things like pfm_initialize() only need
to be called in the parent thread).  Is that correct at all?

So I'm wondering if it would help in the documentation if you could
distinguish between these two cases in some way.  That would make it
clearer (for me, at least).  I'm not sure how to do this in a way that
is independent of the way you started
the threads though.  Perhaps you can use the words "once per context" or
some such.

Or is this all covered someplace in the docs that I haven't found yet?

Thanks,
-- 
Best Regards,
Ray
-----------------------------------------------
Ray Bryant               SGI
512-453-9679 (work)      512-507-7807 (cell)
raybry@sgi.com           raybry@austin.rr.com
-----------------------------------------------

