From: "Hoeflinger, Jay P" <jay.p.hoeflinger@intel.com>
Date: Tue, 15 Apr 2003 15:13:31 +0000
Subject: [Linux-ia64] Re: ias and stack unwind
Message-Id: <marc-linux-ia64-105590723705505@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It turns out that there was a bug in ias, causing it to put out a bad version
number.  I suppose that is a regression since the version you tested that worked.
There is a new ias ready to be included in the next drop of ecc that puts out 
the correct unwind info.

Jay



>>>>>> On Fri, 11 Apr 2003 14:55:15 -0700, "Hoeflinger, Jay P" <jay.p.hoeflinger@intel.com> said:
>
>  Jay> I don't think that explains it in my case.  I'm using ecc version 7.1.
>
>Ugh, not good.
>
>  Jay> Did you have to use any special options?
>
>Nope, nothing special at all.  Please keep me posted on this.  I very
>much want libunwind to work with all compilers.  I was happy to see
>that ecc 7.0 puts out SCRA-compliant unwind info.  Let's hope it stays
>so.
>
>	--david


