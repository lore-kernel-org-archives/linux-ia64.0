From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 14 Dec 2001 19:13:15 +0000
Subject: Re: [Linux-ia64] Re: Linux 2.4.17-pre6 drm-4.0
Message-Id: <marc-linux-ia64-105590698805696@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805654@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805654@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 8 Dec 2001 13:31:56 +0100, Christoph Hellwig <hch@caldera.de> said:

  Christoph> David, would you remove drm-4.0 from the ia64 patch if I'd do the work
  Christoph> again and package an up-to-date and ia64-capable drm 4.0 out-of-tree?

In my opinion it's extremely bad style to remove drm-4.0 from the 2.4
kernel (remember, it's supposed to be a *stable* kernel series).  As
far as I know, there are binary-only drivers out there that work only
with drm-4.0.  I don't think it's fair to break someones working setup
just because of a kernel upgrade.

But if there is a good reason to remove it, I'm certainly willing to
listen.  My understanding is that for Keith it's good enough if
drm-4.0 goes away in 2.5.

	--david

