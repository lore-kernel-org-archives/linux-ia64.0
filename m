From: Dave Jones <davej@redhat.com>
Date: Fri, 06 Jan 2006 21:00:24 +0000
Subject: Re: [PATCH] ia64: change defconfig to NR_CPUS==1024
Message-Id: <20060106210024.GK4595@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F055A7B6B@scsmsx401.amr.corp.intel.com> <20060106174957.GF19769@parisc-linux.org> <Pine.LNX.4.62.0601060958110.17665@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0601061017510.11324@shark.he.net> <Pine.LNX.4.62.0601061035510.17875@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0601061035510.17875@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: "Randy.Dunlap" <rdunlap@xenotime.net>, Matthew Wilcox <matthew@wil.cx>, "Luck, Tony" <tony.luck@intel.com>, Arjan van de Ven <arjan@infradead.org>, hawkes@sgi.com, Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Dan Higgins <djh@sgi.com>, John Hesterberg <jh@sgi.com>, Greg Edwards <edwardsg@sgi.com>

On Fri, Jan 06, 2006 at 10:37:33AM -0800, Christoph Lameter wrote:
 > On Fri, 6 Jan 2006, Randy.Dunlap wrote:
 > 
 > > > The dicey thing in all of this is that the generic kernels will be used
 > > > for the certification of applications. If the cpu limit is too low then
 > > > applications will simply not be certified for these high processor counts.
 > > > One may encounter problems if the app is then run with a higher processor
 > > > count.
 > > 
 > > Do you equate a 'defconfig' kernel with a generic kernel?
 > > 
 > > I would expect certs to be done on vendor kernels, and as
 > > Arjan has suggested, they will have their own configs,
 > > not defconfig.
 > 
 > Vendors look for the upstream defaults and orient themselves on the 
 > defconfig. It is best to have as much common code and configurations as 
 > possible.

As someone who builds vendor kernels, I can say this isn't true (from my
experience at least).  When a new config option appears, I look at the
Kconfig, and make a decision.  I *never* even look at the defconfig, as
a lot of the time, they are either out of date, or irrelevant.

		Dave

