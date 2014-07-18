From: Tejun Heo <tj@kernel.org>
Date: Fri, 18 Jul 2014 18:01:10 +0000
Subject: Re: [RFC 0/2] Memoryless nodes and kworker
Message-Id: <20140718180110.GD13012@htj.dyndns.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140717230923.GA32660@linux.vnet.ibm.com>
 <20140718112039.GA8383@htj.dyndns.org>
 <CAOhV88PyBK3WxDjG1H0hUbRhRYzPOzV8eim5DuOcgObe-FtFYg@mail.gmail.com>
 <20140718180008.GC13012@htj.dyndns.org>
In-Reply-To: <20140718180008.GC13012@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nish Aravamudan <nish.aravamudan@gmail.com>
Cc: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Jiang Liu <jiang.liu@linux.intel.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Jul 18, 2014 at 02:00:08PM -0400, Tejun Heo wrote:
> This isn't a huge issue but it shows that this is the wrong layer to
> deal with this issue.  Let the allocators express where they are.
                                 ^
				 allocator users
> Choosing and falling back belong to the memory allocator.  That's the
> only place which has all the information that's necessary and those
> details must be contained there.  Please don't leak it to memory
> allocator users.

-- 
tejun
