From: Bill Nottingham <notting@redhat.com>
Date: Mon, 07 Jun 2004 20:09:12 +0000
Subject: Re: lib64 in fedora glibc
Message-Id: <20040607200912.GA8394@nostromo.devel.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040528214105.GK9115@mustard.zk3.dec.com>
In-Reply-To: <20040528214105.GK9115@mustard.zk3.dec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Saxena, Sunil (sunil.saxena@intel.com) said: 
> on Friday, June 04, 2004 1:21 PM, Bill Nottingham wrote :
> > Actually, most x86-64 stuff is native too. Where this normally
> > hits with ISVs is their middleware apps. Apparently, ISVs are
> > averse to rebuilding their custom-changed Apache or databases,
> > and want to just run the x86 binaries.
> > 
> We did not receive any complaints from any ISVs for running x86 binaries
> today.
> I agree that they may have gone through some irritation to get it to
> work.  I 
> would love know details of the cases where you saw this did not work.

Pretty simple... install all the x86 RPMs required to run x86
OpenOfffice.... it will not start, due to it being unable to
find its library directories.

Bill
