From: William Lee Irwin III <wli@holomorphy.com>
Date: Thu, 02 Sep 2004 05:18:45 +0000
Subject: Re: page fault scalability patch final : i386 tested, x86_64 support added
Message-Id: <20040902051845.GW5492@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040816143903.GY11200@holomorphy.com> <B6E8046E1E28D34EB815A11AC8CA3129027B679F@mtv-atc-605e--n.corp.sgi.com> <B6E8046E1E28D34EB815A11AC8CA3129027B67A9@mtv-atc-605e--n.corp.sgi.com> <B6E8046E1E28D34EB815A11AC8CA3129027B67B4@mtv-atc-605e--n.corp.sgi.com> <Pine.LNX.4.58.0408271616001.14712@schroedinger.engr.sgi.com> <1094012689.6538.330.camel@gaston> <Pine.LNX.4.58.0409010938200.9907@schroedinger.engr.sgi.com> <1094080164.4025.17.camel@gaston> <Pine.LNX.4.58.0409012140440.23186@schroedinger.engr.sgi.com> <20040901215741.3538bbf4.davem@davemloft.net>
In-Reply-To: <20040901215741.3538bbf4.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>
Cc: Christoph Lameter <clameter@sgi.com>, benh@kernel.crashing.org, akpm@osdl.org, davem@redhat.com, raybry@sgi.com, ak@muc.de, manfred@colorfullife.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, vrajesh@umich.edu, hugh@veritas.com

On Wed, 1 Sep 2004 21:45:20 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:
>> Where would I find that patch?

On Wed, Sep 01, 2004 at 09:57:41PM -0700, David S. Miller wrote:
> Attached.
> It's held up because it needs to be ported to all platforms
> before we can consider it seriously for inclusion and
> only sparc64 and ppc{,64} are converted.

Nice, I guess I can port this to a few arches. Maybe this is a good
excuse get my new (to me) Octane running, too.


-- wli
