From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 23 Sep 2003 18:47:48 +0000
Subject: Re: libelf package
Message-Id: <marc-linux-ia64-106434326809373@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106401166405460@msgid-missing>
In-Reply-To: <marc-linux-ia64-106401166405460@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 22 Sep 2003 19:32:01 -0700, Jim Wilson <wilson@specifixinc.com> said:

  Jim> On Mon, 2003-09-22 at 13:52, David Mosberger wrote:
  >> For what it's worth, Debian has a libelf package.  Not that this helps
  >> with United Linux...

  Jim> I looked at the Debian package, it is the wrong one.  The SuSE package
  Jim> is probably the same wrong one.

For some definition of "wrong". ;-)

  Jim> There is a libelf project that Ulrich Drepper is working on, which he
  Jim> hopes will replace the bfd library in binutils some day.  Quite a few
  Jim> people have heard of this by now.

Yes, I've heard of it many times before, though not as "libelf".

  Jim> There is also a libelf project that was written by Michael Riepe, Uni
  Jim> Hannover.  I'd never heard of this one before today, and I doubt many
  Jim> others have either.

AFAIK, it's a fairly standard interface.  I certainly have known about
it for years and I suspect many others do, too.

  Jim> Ulrich's project is very much a Red Hat project.

Yes.

  Jim> The only way to get it that I know of it to get an RPM from Red
  Jim> Hat.  This will have to change if he wants to replace bfd, but
  Jim> that is the way it is for now.  This is in the elfutils
  Jim> package, even though everyone calls it libelf, probably to try
  Jim> to avoid confusion with the other libelf project.

I looked at the source code of elfutils and it seems to me that the
libelf.h/libelf.so included there is API-compatible with the libelf by
Michael Riepe (which is good, I suppose...).

	--david
