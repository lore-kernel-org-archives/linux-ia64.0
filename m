From: Paul Jackson <pj@sgi.com>
Date: Fri, 19 Sep 2003 17:49:33 +0000
Subject: Re: [PATCH] fix build_zonelists for CONFIG_ACPI_NUMA
Message-Id: <marc-linux-ia64-106399362616844@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106383460616067@msgid-missing>
In-Reply-To: <marc-linux-ia64-106383460616067@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Too bad we can't have user level code build the zone lists, and just
have the kernel use whatever zone list it is told to use.  Keep
mechanism in the kernel and policy outside, where possible.

Should we have a zone list per task, or per vma?  I can imagine cases
where an application might want to place some of its memory differently,
perhaps to get some pages near dma hardware or some other sharing user.

The kernel as well, in addition to tasks or vmas, should have lists
controlling memory placement, depending on which cpu is asking.

Essentially nothing is needed at boot, other than the ability to place
a couple of kernel threads on each cpu or node for specific reasons.

Anything fancier could be setup from initscripts, if we presume we
have enough locking (rcu?) in place to allow the rare change of the
kernel's. or some other process's (init pid=1?) zone lists.

Lists of lists, or 2D arrays of numbers, are a pain to get across the
kernel boundary.  Seems we are getting comfortable with getting such
_out_ of the kernel, using pseudo file system apis with small files
having trivial syntax (like a single ascii number).  I'd like to see us
pushing lists and arrays of numbers such as zone lists back _into_ the
kernel this way, writing to pseudo file systems.  Is that becoming an
acceptable mechanism (beats ioctls and the like ...)?

-- 
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373
