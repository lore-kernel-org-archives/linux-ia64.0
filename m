From: Mike Shaver <shaver@mozilla.org>
Date: Tue, 15 May 2001 15:56:46 +0000
Subject: [Linux-ia64] Re: mozilla/ia64 patch
Message-Id: <marc-linux-ia64-105590693005582@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:

> Below is a patch that makes mozilla work on IA-64 (native, not via
> IA-32 emulation).


I'll try and get this stuff into the tree before 0.9.1, including build 
mechanics for determining if we need to link against libffi, and 
verifying that it's present.

I'll also attach the libffi patch to the IA/64 xptcall bug, for the 
brave users who want to work with it.

Does anyone out there want to apply this patch to the 0.9 tree and do a 
build with a static libffi linkage?  I'd be overjoyed to put such a 
build on our site.

Thanks a million, David, for your work here.  You're a star.

Mike


