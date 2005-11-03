From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 03 Nov 2005 19:59:00 +0000
Subject: RE: [RFC] 4-level page table directories.
Message-Id: <200511031959.jA3Jx0g29354@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Robin Holt wrote on Thursday, November 03, 2005 8:37 AM
> On Wed, Nov 02, 2005 at 05:53:10PM -0800, Chen, Kenneth W wrote:
> > I just did a quick measurement with I/O submission path.  get_user_pages
> > is my biggest concern that extra level means more code and cache foot
> > print for each I/O submission.  It cost about 1.5% more in I/O path
> > length on a micro-benchmark (from block layer and Up).  This could be
> > all buried as noise in a larger scheme for industry database benchmark.
> 
> Can you point me at the benchmark?

Here, kernel null blk driver:
http://marc.theaimsgroup.com/?l=linux-kernel&m1033439400836&w=2


And here: user space micro-benchmark:
http://marc.theaimsgroup.com/?l=linux-kernel&m1033404219628&w=2


- Ken

