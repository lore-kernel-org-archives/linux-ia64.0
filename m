From: Jes Sorensen <jes@wildopensource.com>
Date: Wed, 16 Feb 2005 07:32:11 +0000
Subject: Re: [rfc] generic allocator and mspec driver
Message-Id: <yq0y8dpneo4.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <16897.9640.160896.31584@jaguar.mkp.net>
In-Reply-To: <16897.9640.160896.31584@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Robin" = Robin Holt <holt@sgi.com> writes:

Robin> On Tue, Feb 15, 2005 at 03:02:01PM -0500, Jes Sorensen wrote:
>> I don't see any valid such cases. In principle one has to go
>> through the reverse procedure to convert something from uncached to
>> cached and since we don't do that in any place I don't see any
>> valid reason to do so. Anyone doing it in kdb etc. would be in for
>> what they are getting, so I don't think thats valid concern.

Robin> I guess I didn't follow you.  Are you saying you would have no
Robin> concern with changing the memory protections to prevent that
Robin> type of reference?

Yes

Jes
