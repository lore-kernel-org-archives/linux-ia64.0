From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 07 May 2003 22:39:11 +0000
Subject: [Linux-ia64] Re: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705658@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Jesse,

I thought I had responded to this already, but my mailer claims otherwise.

>>>>> On Fri, 25 Apr 2003 14:02:20 -0700, Jesse Barnes <jbarnes@sgi.com> said:

  Jesse> On Thu, Apr 17, 2003 at 04:05:29PM -0700, David Mosberger wrote:
  >> I don't have an issue with the particular patch, but I don't like to
  >> take new features incrementally.  At the moment, the normal ia64
  >> kernel doesn't support loading at arbitrary physical addresses.  If
  >> there is a complete patch to add such a feature, we should consider it
  >> for inclusion.

  Jesse> Chris Wedgwood reminded me that Tony posted one awhile back.  I wonder
  Jesse> what you think of his approach?  I've attached it for reference since
  Jesse> the linux-ia64 archive only had a mangled copy.  It's against 2.5.39.
  Jesse> If you have any other ideas about how we can address this, I'd like to
  Jesse> hear them.  Ideally, a generic kernel would work on all ia64 platforms
  Jesse> at the same virtual load address (which is one problem with Tony's old
  Jesse> patch IMO), regardless of physical load address.

Keeping the load address the same would definitely make life easier.
Otherwise, any tool that depends on System.map may break.

To be honest, conceptually, I prefer boot-time relocation, because it
keeps the kernel model simpler (and there is already relocation code
in the in-kernel module loader which you could leverage).  But having
the kernel text addresses vary from one machine to another, depending
on memory configuration is not a exactly a pleasant thought.  I don't
really have much of a stake in this, so I'd like the folks who really
care to work out a patch that works on all ia64 NUMA platforms and
then convince me why it's a good idea to include that patch and why
it's really The Right Thing.

	--david

