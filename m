From: Jes Sorensen <Jes.Sorensen@cern.ch>
Date: Thu, 06 Apr 2000 16:55:45 +0000
Subject: Re: [Linux-ia64] using csh
Message-Id: <marc-linux-ia64-105590678205005@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205004@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205004@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Chris" = Satterthwaite, Chris <chris.satterthwaite@intel.com> writes:

Chris> To further set up our Linux testing environment, I need to
Chris> obtain a copy of a working 64-bit version of csh, or find out
Chris> how to properly fix the current 32-bit version.  When I set up
Chris> the dynamic libraries that the 32-bit version uses, check the
Chris> LD_LIBRARY_PATH and PATH variables, and throw the binary into
Chris> my /bin32, it gives a segmentation fault and issues a core
Chris> dump. Any ideas?

Hi

Did you look in the RPMS that Turbo released, I see they have a tcsh
RPM there (ftp://ftp.turbolinux.com/linux/tl-ia64-pre1/). I do have a
binary I can put up for you if you want, however it requires shared
libraries.

Jes


