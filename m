From: Jes Sorensen <jes@wildopensource.com>
Date: Tue, 15 Feb 2005 08:44:26 +0000
Subject: Re: [rfc] generic allocator and mspec driver
Message-Id: <yq0bramp5zp.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <16897.9640.160896.31584@jaguar.mkp.net>
In-Reply-To: <16897.9640.160896.31584@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:

>>>>> On Mon, 14 Feb 2005 11:12:54 -0800, "Luck, Tony" <tony.luck@intel.com> said:
Tony> If so, the PG_arch_1 might have to be the solution

David> Note that PG_arch_1 is already being used as a "i-cache
David> coherent" flag.

Ahh, so not totally off. It's also used for internal debugging in
reiser4, but I'll happily ignore that while waving the 'friends don't
let friends run reiser4' flag ;)

Cheers,
Jes
