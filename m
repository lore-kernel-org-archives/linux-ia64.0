From: Christoph Hellwig <hch@caldera.de>
Date: Sat, 08 Dec 2001 12:31:56 +0000
Subject: Re: [Linux-ia64] Re: Linux 2.4.17-pre6 drm-4.0
Message-Id: <marc-linux-ia64-105590698805662@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805654@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805654@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, Dec 08, 2001 at 11:35:43AM +0000, Alan Cox wrote:
> > to get rid of them asap.  The SiS direct render is only for drm 4.1 so
> > now is a good time to question if 4.0 is still required.
> 
> That argument doesnt fly. The 4.0 DRM is the only working GMX renderer..

So what DRM can build out of tree easily - e.g. the Caldera LTP
(3.1 early access) had a DRM package built completly out of tree.

David, would you remove drm-4.0 from the ia64 patch if I'd do the work
again and package an up-to-date and ia64-capable drm 4.0 out-of-tree?

	Christoph

-- 
Of course it doesn't work. We've performed a software upgrade.

