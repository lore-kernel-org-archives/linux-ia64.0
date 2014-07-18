From: Tejun Heo <tj@kernel.org>
Date: Fri, 18 Jul 2014 18:19:47 +0000
Subject: Re: [RFC 0/2] Memoryless nodes and kworker
Message-Id: <20140718181947.GE13012@htj.dyndns.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140717230923.GA32660@linux.vnet.ibm.com>
 <20140718112039.GA8383@htj.dyndns.org>
 <CAOhV88PyBK3WxDjG1H0hUbRhRYzPOzV8eim5DuOcgObe-FtFYg@mail.gmail.com>
 <20140718180008.GC13012@htj.dyndns.org>
 <CAOhV88O03zCsv_3eadEKNv1D1RoBmjWRFNhPjEHawF9s71U0JA@mail.gmail.com>
In-Reply-To: <CAOhV88O03zCsv_3eadEKNv1D1RoBmjWRFNhPjEHawF9s71U0JA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nish Aravamudan <nish.aravamudan@gmail.com>
Cc: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Jiang Liu <jiang.liu@linux.intel.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hello,

On Fri, Jul 18, 2014 at 11:12:01AM -0700, Nish Aravamudan wrote:
> why aren't these callers using kthread_create_on_cpu()? That API was

It is using that.  There just are other data structures too.

> already change to use cpu_to_mem() [so one change, rather than of all over
> the kernel source]. We could change it back to cpu_to_node and push down
> the knowledge about the fallback.

And once it's properly solved, please convert back kthread to use
cpu_to_node() too.  We really shouldn't be sprinkling the new subtly
different variant across the kernel.  It's wrong and confusing.

> Yes, this is a good point. But honestly, we're not really even to the point
> of talking about fallback here, at least in my testing, going off-node at
> all causes SLUB-configured slabs to deactivate, which then leads to an
> explosion in the unreclaimable slab.

I don't think moving the logic inside allocator proper is a huge
amount of work and this isn't the first spillage of this subtlety out
of allocator proper.  Fortunately, it hasn't spread too much yet.
Let's please stop it here.  I'm not saying you shouldn't or can't fix
the off-node allocation.

Thanks.

-- 
tejun
