From: Matthew Wilcox <matthew@wil.cx>
Date: Fri, 06 Jan 2006 18:07:11 +0000
Subject: Re: [PATCH] ia64: change defconfig to NR_CPUS==1024
Message-Id: <20060106180711.GG19769@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F055A7B6B@scsmsx401.amr.corp.intel.com> <20060106174957.GF19769@parisc-linux.org> <Pine.LNX.4.62.0601060958110.17665@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0601060958110.17665@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Arjan van de Ven <arjan@infradead.org>, hawkes@sgi.com, Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Dan Higgins <djh@sgi.com>, John Hesterberg <jh@sgi.com>, Greg Edwards <edwardsg@sgi.com>

On Fri, Jan 06, 2006 at 10:04:56AM -0800, Christoph Lameter wrote:
> On Fri, 6 Jan 2006, Matthew Wilcox wrote:
> > You can use that argument to set the CPU limit low too -- since a kernel
> > with a CPU limit lower than the number of CPUs in the box will just ignore
> > the additional ones, people who want to get the additional performance
> > will tune limits that are set lower than they need ;-)
> 
> The dicey thing in all of this is that the generic kernels will be used 
> for the certification of applications. If the cpu limit is too low then 

Why on earth would somebody do that?
