From: Jim Wilson <wilson@specifixinc.com>
Date: Tue, 23 Sep 2003 02:32:01 +0000
Subject: Re: libelf package
Message-Id: <marc-linux-ia64-106428434114681@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106401166405460@msgid-missing>
In-Reply-To: <marc-linux-ia64-106401166405460@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2003-09-22 at 13:52, David Mosberger wrote:
> For what it's worth, Debian has a libelf package.  Not that this helps
> with United Linux...

I looked at the Debian package, it is the wrong one.  The SuSE package
is probably the same wrong one.

There is a libelf project that Ulrich Drepper is working on, which he
hopes will replace the bfd library in binutils some day.  Quite a few
people have heard of this by now.

There is also a libelf project that was written by Michael Riepe, Uni
Hannover.  I'd never heard of this one before today, and I doubt many
others have either.  This is the one in RHL8, and Debian.

Ulrich's project is very much a Red Hat project.  The only way to get it
that I know of it to get an RPM from Red Hat.  This will have to change
if he wants to replace bfd, but that is the way it is for now.  This is
in the elfutils package, even though everyone calls it libelf, probably
to try to avoid confusion with the other libelf project.
-- 
Jim Wilson, GNU Tools Support, http://www.SpecifixInc.com

