From: "Jeff V. Merkey" <jmerkey@timpanogas.com>
Date: Mon, 19 Jun 2000 20:49:24 +0000
Subject: [Linux-ia64] [Fwd: IA64 version of 2.4.0-test1 has compile errors/config errors]
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------990877FC980AF40390784667"
Message-Id: <marc-linux-ia64-105590678205165@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------990877FC980AF40390784667
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

 
--------------990877FC980AF40390784667
Content-Type: message/rfc822
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

X-Mozilla-Status2: 00000000
Message-ID: <394E84FE.520F31A6@timpanogas.com>
Date: Mon, 19 Jun 2000 14:39:26 -0600
From: "Jeff V. Merkey" <jmerkey@timpanogas.com>
Organization: TRG, Inc.
X-Mailer: Mozilla 4.7 [en] (WinNT; I)
X-Accept-Language: en
MIME-Version: 1.0
To: Jes Sorensen <jes@linuxcare.com>
CC: linux-kernel@vger.rutgers.edu
Subject: Re: IA64 version of 2.4.0-test1 has compile errors/config errors
References: <394E69D0.E867BCBF@timpanogas.com> <d3ya41v3wn.fsf@lxplus007.cern.ch>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


"Separate but equal" was ruled by the US Supreme Court to be an invalid
concept relative to civil rights cases -- I think it's probably a good
precedent for Linux.  I understand that the IA64 folks should get the
message in the most efficient manner possible, but unless I am mistaken,
there's only "one" master Linux tree, and unless the two are planned to
diverge, www.kernel.org should be the central repository for IA64, just
like any other Linux port, otherwise, we get the current situation --
the build at www.kernel.org is not always current or at the expected
level of completeness that the rest of Linux enjoys.  It took me over
four hours Sunday to locate and download all the patches and fixes from
www.ia64linux.org and hp.com to get the build from www.kernel.org to
even compile for IA64.  It was a "jolting" experience, and I could see
where your average Linux user who was trying to get IA64 Linux up and
running could be left with the impression that it's "not quite cooked".

At any rate, I'll forward it on, but this list should be the correct
forum for Linux general issues, and at some point, IA64 should merge
competely with this linux effort, since it's the primary source for most
people on Planet Earth who run Linux.

:-)

Very Truly Yours,

Jeff


Jes Sorensen wrote:
> 
> >>>>> "Jeff" == Jeff V Merkey <jmerkey@timpanogas.com> writes:
> 
> Jeff> The IA64 build of 2.4.0-test1 reports type mismatch errors for
> Jeff> strlen() and memset() with the latest build of linux-2.4.0-test1
> Jeff> at www.kernel.org when you build the kernel under the NUE
> Jeff> environment with the GCC IA64 compiler/linker.  The compile
> Jeff> error indicates a conflict with built in functions with the same
> Jeff> name.
> 
> It would be a good idea if you used the linux-ia64@linuxia64.org
> mailing list for this kinda stuff as instructed on the Web page where
> you downloaded SKI and NUE. There is a much bigger chance that the
> appropriate people will read it there.
> 
> Jeff> Also, IA32 emulation support is listed in .config as
> Jeff> "experimental", but seems to work ok when enabled.  The lack of
> Jeff> loadable module support also seems troublesome.  I am assuming
> Jeff> modutils have not been modified to support IA64?
> 
> There is currently no module support, though it should be coming
> shortly.
> 
> Jes

--------------990877FC980AF40390784667--



