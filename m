From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 22 Jan 2014 00:53:39 +0000
Subject: RE: Kernel compiled with gcc-4.6+ fails to boot on ia64
Message-Id: <3908561D78D1C84285E8C5FCA982C28F31DB359D@ORSMSX106.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3908561D78D1C84285E8C5FCA982C28F31DB1BDA@ORSMSX106.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F31DB1BDA@ORSMSX106.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> I'd start off with using the old compiler
>> for arch/ia64/kernel/* (perhaps arch/ia64/mm/* too) and the new
>> compiler for everything else.
>
> Thanks for your suggestion. How do I do that properly?
> I think the following will not work, because changing CC will cause
> arch/ia64/kernel to be rebuild, right?
> # make -C arch/ia64/kernel CC=gcc-4.7.3
> # make CC=gcc-4.5.4

yes - you'd have to fake Kbuild/make into thinking you were using the same compiler
all the time.  I don't know if there is a "proper" way to do that.  I'd do it by writing
a shell script "mycc" that in pseudo-code looks like:

---------
#!/bin/bash

USECC=gcc-4.7.3
# Look to see if we have a ".c" file argument on a special list
for i
do case "$i" in
     *.c)
               if grep -s "^$i$" ~/special
	  then
		USECC=gcc4.5.4
	  fi
	;;
    esac
done

$USECC "$@"
----------

Then start with:
$ find arch/ia64/kernel arch/ia64/mm -name "*.c" > ~/special
$ make CC=mycc

[Warning: I've never tried anything like this]

> And what would you suggest to add after ia64/kernel and ia64/mm? I do
> not know much about the parts of the kernel that run at this early
> stage.

Not a clue.  If My guess that the problem is in those arch specific files, then
you have a list of ~64 to play with ... bisection would get you to one (if just
one is the root of the problem) in six builds.

If I'm wrong ... well the full list of files built in a typical configuration
is a couple of thousand.  So eleven builds.

If the problem is in a static inline" - well none of this will help :-(

-Tony
