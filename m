From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Wed, 11 Dec 2002 17:14:20 +0000
Subject: Re: [Linux-ia64] a couple questions on pfmon-2.0
Message-Id: <marc-linux-ia64-105590709805544@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805539@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805539@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ray,

On Tue, Dec 10, 2002 at 04:11:24PM -0600, Ray Bryant wrote:
> Stephane,
> 
> There are both 2.0 and 2.0-1 versions mentioned in your note.  Are these
> versions signifcantly different?? which one should we be using?
> 
That's the same version. The -1 comes from RPM version number. 

> WRT documentation -- this is great, much improved.  One question I still
> had is the following:  If I fork a child process, after calling
> pfm_initialize(), and, assuming we bind threads to processors in some
> fashion, do I need to call pfm_initialize() again in the child thread? 
> What if the child thread is created by pthread_create()?

Yes, pfm_initialize() only needs to be called once per application. It
is used to autodetect the host PMU. 

> 
> My experience with this is that most routines have to be called on the
> thread (e. g. things that get or set PMU regs have to be called in the
> appropriate child process, whilst things like pfm_initialize() only need
> to be called in the parent thread).  Is that correct at all?

> 
> So I'm wondering if it would help in the documentation if you could
> distinguish between these two cases in some way.  That would make it
> clearer (for me, at least).  I'm not sure how to do this in a way that
> is independent of the way you started
> the threads though.  Perhaps you can use the words "once per context" or
> some such.
> 

The library is threadsafe. It is important to keep in mind that
the library NEVER invokes the perfmonctl() system call. As such, the library 
functions can be called from anywhere, the master thread or worker threads. 
The case of pfm_initialize() is kind of unique. What you see in pfmon is 
just one way of using the library. For pfmon and in case of system wide 
monitoring, all the CPUS monitor the same set of events, so we prepare 
the arguments to the perfmonctl() once in the master thread and then we 
simply use them in all the pinned worker threads. The CPU-specific information
is mostly in the pfarg_context_t argument which is not a library data structure
but a kernel structure.

> Or is this all covered someplace in the docs that I haven't found yet?

No, but I will make the clarification in the man pages.

-- 
-Stephane

