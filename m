From: Jes Sorensen <jes@wildopensource.com>
Date: Tue, 15 Feb 2005 20:02:01 +0000
Subject: Re: [rfc] generic allocator and mspec driver
Message-Id: <yq03bvxpp6u.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <16897.9640.160896.31584@jaguar.mkp.net>
In-Reply-To: <16897.9640.160896.31584@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Robin" = Robin Holt <holt@sgi.com> writes:

Robin> Would anybody have a concern with marking those cache lines as
Robin> processor uncached only?  Would there ever be a time that we
Robin> would expect _ANY_ type of cached reference when the granule is
Robin> being used for uncached that would be an acceptable use?

Robin,

I don't see any valid such cases. In principle one has to go through
the reverse procedure to convert something from uncached to cached and
since we don't do that in any place I don't see any valid reason to do
so. Anyone doing it in kdb etc. would be in for what they are getting,
so I  don't think thats valid concern.

Cheers,
Jes
