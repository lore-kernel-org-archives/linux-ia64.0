From: Paul Jackson <pj@sgi.com>
Date: Wed, 19 May 2004 10:22:59 +0000
Subject: Re: [Lhns-devel] Re: Who's doing what with cpu/memory/node hotplug?
Message-Id: <20040519032259.20bb47da.pj@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040513150842.22F5.YGOTO@us.fujitsu.com>
In-Reply-To: <20040513150842.22F5.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Matthias wrote:
> But doesn't a true hotplug implementation ... require ... "on-the-fly scaling" ?

You'd have to ask the hotplug folks that.  I'd imagine that they will
have some work to do before they can go from one to 512 cpus in a single
partition boot and still keep a sensible configuration.

-- 
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373
