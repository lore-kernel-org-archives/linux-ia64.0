From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 02 Dec 2004 01:46:04 +0000
Subject: Re: page fault scalability patch V12 [0/7]: Overview and performance
Message-Id: <Pine.LNX.4.58.0412011745090.6430@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0411221457240.2970-100000@localhost.localdomain>
 <Pine.LNX.4.58.0411221343410.22895@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0411221419440.20993@ppc970.osdl.org>
 <Pine.LNX.4.58.0411221424580.22895@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0411221429050.20993@ppc970.osdl.org>
 <Pine.LNX.4.58.0412011539170.5721@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0412011608500.22796@ppc970.osdl.org> <20041201165538.015ee7a6.akpm@osdl.org>
In-Reply-To: <20041201165538.015ee7a6.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: Linus Torvalds <torvalds@osdl.org>, hugh@veritas.com, benh@kernel.crashing.org, nickpiggin@yahoo.com.au, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 1 Dec 2004, Andrew Morton wrote:

> > Ok, consider me convinced. I don't want to apply this before I get 2.6.10
> > out the door, but I'm happy with it.
>
> There were concerns about some architectures relying upon page_table_lock
> for exclusivity within their own pte handling functions.  Have they all
> been resolved?

The patch will fall back on the page_table_lock if an architecture cannot
provide atomic pte operations.

