From: Jes Sorensen <jes@sgi.com>
Date: Wed, 20 Dec 2006 09:31:12 +0000
Subject: Re: [patch 3/3] IA64: virt_to_page() can be called with NULL arg
Message-Id: <yq0slfasylb.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <200612192104.kBJL4iBg010376@shell0.pdx.osdl.net>
In-Reply-To: <200612192104.kBJL4iBg010376@shell0.pdx.osdl.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "akpm" = akpm  <akpm@osdl.org> writes:

akpm> From: Kirill Korotaev <dev@openvz.org> It does not return NULL
akpm> when arg is NULL.

Shouldn't the real fix be to track down who calls virt_to_page() with
a NULL pointer? IMHO it is bogus to do so.

Cheers,
Jes
