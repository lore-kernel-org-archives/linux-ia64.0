From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 04 May 2004 18:20:11 +0000
Subject: Re: [RFC] I/O MCA recovery
Message-Id: <16535.57051.469403.11537@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405040954.09524.jbarnes@engr.sgi.com>
In-Reply-To: <200405040954.09524.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 4 May 2004 11:07:41 -0700, Jesse Barnes <jbarnes@engr.sgi.com> said:

  Jesse> On Tuesday, May 4, 2004 10:43 am, David Mosberger wrote:
  >> Eh, I/O space is required to soft-fail, isn't it?

  Jesse> I thought so too, but I haven't been able to find the spec
  Jesse> that contains that requirement.

It's certainly implied.

  >> Why can't you hide this in the platform-specific inX/outX routines?  I
  >> suppose it would be very slow to drain MCAs after every inX/outX, but
  >> you'd have to do the slow part only once, until you know whether or
  >> not the given I/O address is safe.

  Jesse> This is I/O initiated by userspace loads/stores, so unless I
  Jesse> wrap every in/out with some sort of ioctl or something, those
  Jesse> won't help me.

User-level accesses are mapped via the MMU so you could always
intercept the page-faults.

  Jesse> Also, with this scheme, we could potentially recover from
  Jesse> regular read/writes too.

_If_ there is an infrastructure what you can hook into, fine.  But I'm
highly suspicious of using broken platforms as a justification for new
infrastructure.

	--david
