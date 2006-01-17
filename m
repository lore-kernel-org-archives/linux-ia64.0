From: Jes Sorensen <jes@sgi.com>
Date: Tue, 17 Jan 2006 10:37:20 +0000
Subject: Re: [PATCH]: ia64/sn: Older PROM WAR for device flush code
Message-Id: <yq0r777qgwv.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060116203101.7794.18322.sendpatchset@prarit.boston.redhat.com>
In-Reply-To: <20060116203101.7794.18322.sendpatchset@prarit.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Prarit" = Prarit Bhargava <prarit@sgi.com> writes:

Prarit> Work-around to temporarily support older PROMs with new flush
Prarit> device code.  This code allows systems running older PROMs to
Prarit> continue to run on the new kernel base until a new official
Prarit> PROM is released.

Looks good, even works for me ;-) I'd say we should keep this in for a
couple of months at least, say through 2.6.17 or so, to give the new
PROM time to propagate out.

Prarit> Signed-off-by: Prarit Bhargava <prarit@sgi.com>

Acked-by: Jes Sorensen <jes@sgi.com>

Cheers,
Jes
