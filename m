From: Jes Sorensen <jes@sgi.com>
Date: Thu, 30 Mar 2006 10:11:07 +0000
Subject: Re: [Fedora-ia64-list] kernel 2.6.16-1.2097_FC6 unbootable on Itanium
Message-Id: <yq0hd5guts4.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <442AB6DD.4020800@sgi.com>
In-Reply-To: <442AB6DD.4020800@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Keith" = Keith Owens <kaos@sgi.com> writes:

Keith> Jes Sorensen (on 30 Mar 2006 03:57:04 -0500) wrote:
>> Please note that if I compile the kernel on a box with an old
>> installation and old toolchain the kernel boots, same source tree
>> built on a system with a new installation and it doesn't boot.

Keith> This sounds like a random data overwrite which depends on the
Keith> exact kernel layout.  Somebody else in SGI (Prarit ?) said that
Keith> they compiled your failing tree on the same platform and their
Keith> kernel worked.  Since the build userid and the pathname to the
Keith> kernel source tree are embedded in the binary, changing either
Keith> of those will disturb the kernel layout, possibly making the
Keith> problem move.

Keith> Jes, try renaming your source tree to something with a
Keith> different pathname length and rebuild the kernel.  Does the
Keith> problem change or go away?

Moved it to /tmp/a and built there - no go.

Cheers,
Jes
