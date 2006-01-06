From: Arjan van de Ven <arjan@infradead.org>
Date: Fri, 06 Jan 2006 17:24:16 +0000
Subject: RE: [PATCH] ia64: change defconfig to NR_CPUS==1024
Message-Id: <1136568256.2940.50.camel@laptopd505.fenrus.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F055A7AFB@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F055A7AFB@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: hawkes@sgi.com, Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Dan Higgins <djh@sgi.com>, John Hesterberg <jh@sgi.com>, Greg Edwards <edwardsg@sgi.com>

On Fri, 2006-01-06 at 09:19 -0800, Luck, Tony wrote:
> >> Increase the generic ia64 config from its current max of 512 CPUs to a
> >> new max of 1024 CPUs.
> >
> >I wonder why this would be seen as a sane thing...
> >Very few people have 1024 cpus, and the ones that do sure would know how
> >to set 1024 in their kernel config. In fact I would argue to lower it. I
> >can see the point of keeping it over 64, to give the
> >more-cpus-than-a-long code more testing, but 512 is too high already..
> >most people who have ia64 will not have 512 cpus.
> 
> Would it be impossibly hard to make the >64 cpus case (when the code
> switches from a single word to an array) be dependent on a boot-time
> variable?  If we could, then the defconfig could just say 128, and
> users of monster machines would just boot with "maxcpus@96" to increase
> the size of the bitmask arrays.

variable size runtime cpu count.. that's beside the point for this
change though. The *default* shouldn't be insanely high, but more
represent a "typical" setup. The *maximum* is of course an entirely
different thing. So.. I'd say lower the default from 512 to 128 (just to
get the default to be the "complex case", which has benefits). Going to
1024 for a per user default is silly. Just about everyone will change it
anyway to something lower. And distros set their own regardless.


