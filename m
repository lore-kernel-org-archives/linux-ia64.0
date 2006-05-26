From: Christoph Hellwig <hch@infradead.org>
Date: Fri, 26 May 2006 13:42:33 +0000
Subject: Re: dropping CONFIG_IA32_SUPPORT from ia64
Message-Id: <20060526134233.GA2185@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200605241438.34303.bjorn.helgaas@hp.com>
In-Reply-To: <200605241438.34303.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, May 26, 2006 at 03:11:03AM -0400, Jes Sorensen wrote:
> Yup, Firefox runs nicely, now we just need gnash to get there so it
> can display some of those %#@%#$$@# sites that insist on using flash.
> 
> I took a look at trying to build Open Office about two month ago. All
> I can say is YUCK! The build system is disgusting and the arch
> specific bits are a nightmare to try and mess with - after wasting a
> day on it I concluded that it wasn't worth waking up in the middle of
> the night shaking and all soaked in sweat over it. Back to using
> ia32el for it, which unfortunately makes an already utterly slow
> application seem like it's running on my old C64.
> 
> Anyone who manages to get Open Office building natively is very brave
> :)

Indeed.  In addition to your list ooo out of the sun cvs isn't even
64bit clean.  RH and Novell people are working on that though.

