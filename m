From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 15 Nov 2002 01:55:02 +0000
Subject: Re: [Linux-ia64] One little, two little, three little endian...
Message-Id: <marc-linux-ia64-105590709805441@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805439@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805439@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Gavin,

>>>>> On Thu, 14 Nov 2002 16:52:13 -0800, "Gavin Scott" <gavin@allegro.com> said:

  Gavin> Hello list, I want a big endian version of Linux for IPF.
  Gavin> Just how crazy am I?

Very! ;-)

Seriously though: running big-endian processes is the easy part, the
hard part is developing (& maintaining) big-endian versions of all
libraries.  Not only is it a lot of work, but it would also fragment
the ia64 linux market, so I'd consider it a Bad Thing (TM).

  Gavin> Of course both MPE/iX and HP-UX are big-endian environments,
  Gavin> and many of the people I talk to would be very interested in
  Gavin> having an endian-compatible Linux that would run on big
  Gavin> (i.e. IA-64) HP servers.  For this group, x86 compatibility
  Gavin> is probably a non-issue.

It would be a lot easier to add an hp-ux compatibility layer on top of
ia64 linux.  The layer would emulate the (big-endian) hp-ux system
calls and then you would install the big-endian hp-ux libraries on top
of that (e.g., in the /emul/ia64-hpux/ tree).  Of course, I'm ignoring
legal issues here as copying the hp-ux libraries would presumably
require some sort of license.  But legal issues aside, this is doable
and has been done many times before (e.g., alpha linux can run (some)
Tru64 binaries, sparc linux can run sunos/solaris(?) binaries, etc.).

  Gavin> I'm interested in any comments that come to mind.  I'm most
  Gavin> interested in just how complex the task would be from a
  Gavin> technical point of view, either to make the system buildable
  Gavin> either way, or possibly supporting a per-process endian bit
  Gavin> (which would be cool, but probably a lot more work).

Actually, adding a per-process endian bit would be easy.  In fact,
even without, a little-endian program can turn on the big-endian bit
as long as it's prepared to deal with the consequences.  The hard part
is really the libraries.

	--david

