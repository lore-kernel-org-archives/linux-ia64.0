From: Christoph Hellwig <hch@caldera.de>
Date: Sat, 15 Dec 2001 10:19:18 +0000
Subject: Re: [Linux-ia64] Re: Linux 2.4.17-pre6 drm-4.0
Message-Id: <marc-linux-ia64-105590698805704@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805654@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805654@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Dec 14, 2001 at 11:13:15AM -0800, David Mosberger wrote:
> In my opinion it's extremely bad style to remove drm-4.0 from the 2.4
> kernel (remember, it's supposed to be a *stable* kernel series).

Agreed.  Stil I don't think specific ports should fix that up - this
will sooner or later leed to a full fork.

> As
> far as I know, there are binary-only drivers out there that work only
> with drm-4.0.  I don't think it's fair to break someones working setup
> just because of a kernel upgrade.

_Any_ kernel update may break binary drivers.

> But if there is a good reason to remove it, I'm certainly willing to
> listen.  My understanding is that for Keith it's good enough if
> drm-4.0 goes away in 2.5.

My opinion is that including the drm changes in the ia64 patch just makes
the diff to handle much bigger.

Marcelo, are you willing to put in drm 4.0 as option in 2.4.18 again?

	Christoph

-- 
Of course it doesn't work. We've performed a software upgrade.

