From: Jim Wilson <wilson@cygnus.com>
Date: Thu, 27 Jul 2000 20:19:59 +0000
Subject: Re: [Linux-ia64] GLIBC __deregister_frame_pointer compiler error
Message-Id: <marc-linux-ia64-105590678205236@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205235@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205235@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

	While trying to compile glibc on the 2.4 kernel, I get the error messages
	included below.  On 2.3.99, everything compiles fine.  Any ideas where to
	look to solve this?

Something must have changed.  Just changing the kernel shouldn't cause a
previously working build to fail.

However, there is a known problem here.  glibc has a list of routines exported
from libgcc.  This list contains gcc internal EH routines.  This list of EH
routines is now different because of the IA-64 specific EH support.  If
you delete these EH routines from the glibc export list, or if you add the
new IA-64 specific routines, then this problem will go away.  Either way,
you are making an ABI change, so this may require recompiling all libraries
and applications linked against glibc.

The specific file to look at is csu/Versions, and look at section
"Exception handling support functions from libgcc".

Ulrich is already aware of the problem, and is planning to do something about
it, though I don't know exactly what.

I have only seen this problem show up when trying to link against C++ shared
libraries.  Oh, I remember why, whether the problem shows up or not depends
on which order you link in libgcc and glibc.  I don't remember which order
it was that failed, but you can experiment.

The Red Hat OS group deleted all of the EH routines from their version of
glibc to avoid this problem with their builds.

Jim


