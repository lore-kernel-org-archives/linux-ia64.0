From: Christoph Hellwig <hch@ns.caldera.de>
Date: Tue, 18 Sep 2001 10:23:15 +0000
Subject: Re: [Linux-ia64] __emul_prefix() problem
Message-Id: <marc-linux-ia64-105590698805210@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805196@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805196@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Sep 17, 2001 at 04:51:11PM -0700, David Mosberger wrote:
> I'm not sure there is a clean fix to this, but one proposal is
> attached below: it causes __emul_lookup_dentry() to ignore the
> alternate root for paths that resolve to a directory.  This obviously
> could create other problems, but I suspect there is no solution that
> works 100% in all cases (the fundamental being that we now have two
> different root nodes...).

Looks sant to me and doesn't break Linux-ABI.  For 2.5 I'd prefer
to somehow build a per-personality namespace.  Al, do you have an
idea how to keep a secondary namespace alive over the whole uptime
so non-Linu binaries can switch to it all the time (implicitly)?

	Christoph

