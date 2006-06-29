From: Jes Sorensen <jes@sgi.com>
Date: Thu, 29 Jun 2006 08:56:10 +0000
Subject: Re: [Patch] make uncached allocator more node aware
Message-Id: <yq08xngibmd.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <44A2CF61.mailx84S199TB6@aqua.americas.sgi.com>
In-Reply-To: <44A2CF61.mailx84S199TB6@aqua.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Dean" = Dean Nelson <dcn@sgi.com> writes:

Dean> The uncached allocator has a function, uncached_get_new_chunk(),
Dean> that needs to be serialized on a per node basis. It also has a
Dean> global variable, allocated_granules, which should be defined on
Dean> a per node basis and protected by that
Dean> serialization. Additionally, all error returns from functions
Dean> called (like ia64_pal_mc_drain()) should be handled
Dean> appropriately.

Dean> Signed-off-by: Dean Nelson <dcn@sgi.com>

Seems good to me, so:

Acked-by: Jes Sorensen <jes@sgi.com>

Cheers,
Jes
