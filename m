From: "Saxena, Sunil" <sunil.saxena@intel.com>
Date: Mon, 07 Jun 2004 20:05:39 +0000
Subject: RE: lib64 in fedora glibc
Message-Id: <D2984E17C76B534B9B66BB778F2F9D8C024182E2@scsmsx403.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040528214105.GK9115@mustard.zk3.dec.com>
In-Reply-To: <20040528214105.GK9115@mustard.zk3.dec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

on Friday, June 04, 2004 1:21 PM, Bill Nottingham wrote :
> Actually, most x86-64 stuff is native too. Where this normally
> hits with ISVs is their middleware apps. Apparently, ISVs are
> averse to rebuilding their custom-changed Apache or databases,
> and want to just run the x86 binaries.
> 
We did not receive any complaints from any ISVs for running x86 binaries
today.
I agree that they may have gone through some irritation to get it to
work.  I 
would love know details of the cases where you saw this did not work.  I
can 
give you one example of installation where it runs /bin/arch and invokes
the 
compiler to link the objects.  This runs fine in the /emul/ia32-linux
where you have 
all the binaries and utilities in the right place.  I assume that this
can be made to work with some personality utility that would tell the
installer that
it is running on x86 box.  Is that possible?

> Only doing it for some files isn't really practical from a
distribution
> standpoint; keeping tables of what 32-bit stuff goes in 'X', what
> 32-bit stuff goes in 'Y', and what 32-bit stuff goes in 'Z' doesn't
> scale.
> 
I think the challenge is how to support more than two architectures and
multiple data models in a single distribution.  Since ia64 does not have
a 
32-bit native model and 64-bit model is the default model, the /lib
should 
be the default. One could symbolically link /lib to /lib64. Other 
multi-architectures should be put in other identifiable directories..
