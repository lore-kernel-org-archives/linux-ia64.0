From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 07 Mar 2005 19:00:03 +0000
Subject: Re: [patch - 2.6.11-rc5-mm1] genalloc - general purpose allocator
Message-Id: <16940.42163.397058.311057@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16934.4191.474769.320391@jaguar.mkp.net>
	<16934.5385.841758.628631@napali.hpl.hp.com>
	<yq03bvdf8bf.fsf@jaguar.mkp.net>
In-Reply-To: <yq03bvdf8bf.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@wildopensource.com>
Cc: davidm@hpl.hp.com, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

>>>>> On 03 Mar 2005 03:21:56 -0500, Jes Sorensen <jes@wildopensource.com> said:

  Jes> mempool on the other hand will first try and call the user
  Jes> provided allocation function and only if that fails try and
  Jes> take memory from the pool, this will force us to convert pages
  Jes> from cached to uncached if we don't have to.

Ah, that's a good point.

  Jes> [snip...]

  Jes> One could probably do this via mempool, but it would basically
  Jes> require one to put another object allocator below mempool which
  Jes> really makes the whole exercise pointless as this could just as
  Jes> well be done standalone ... ie. genalloc.

It does sound that way, yes.

Thanks,

	--david
