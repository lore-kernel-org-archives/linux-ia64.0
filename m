From: dann frazier <dannf@hp.com>
Date: Thu, 20 Jan 2005 00:54:11 +0000
Subject: Re: state of the ia64 linux tree
Message-Id: <1106182451.12129.92.camel@krebs.dannf>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F02C33881@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F02C33881@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2005-01-19 at 15:19 -0800, Luck, Tony wrote:
> Uni-processor support is a mess right now.  Dan's resurrection
> of Jesse's patches for generic-up support doesn't apply ... the
> prime culprit is discontig.c:find_per_node_space() which has been
> touched by several patches, so we still have lots of build
> errors for generic-up.  tiger and zx1 systems do compile cleanly
> with CONFIG_SMP=n, but the tiger stalls:

2/3 patches were pretty trivial, and aren't interdependent:
http://marc.theaimsgroup.com/?l=linux-ia64&m0504486300806&w=2
http://marc.theaimsgroup.com/?l=linux-ia64&m0504526410939&w=2


