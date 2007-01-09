From: Andrew Morton <akpm@osdl.org>
Date: Tue, 09 Jan 2007 00:16:08 +0000
Subject: Re: +
Message-Id: <20070108161608.4b02c742.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070108152712.ead32a63.akpm@osdl.org>
In-Reply-To: <20070108152712.ead32a63.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 8 Jan 2007 15:29:42 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Mon, 8 Jan 2007, Andrew Morton wrote:
> 
> > Well yeah, but if you're sure that this warning is a false-positive
> > then we could just leave it as-is and whack a comment in there.
> 
> Yes then lets add a comment.

'k

> Isnt there some way to suppress the warning?

Not afaik.  We have a similar false-positive down in acpi which I haven't
worked out how to suppress.
