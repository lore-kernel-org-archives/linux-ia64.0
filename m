From: Sebastien Decugis <sebastien.decugis@ext.bull.net>
Date: Fri, 03 Dec 2004 14:49:51 +0000
Subject: Re: page fault scalability patch V12 [0/7]: Overview and
Message-Id: <1102085391.14792.102.camel@decugiss.frec.bull.fr>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0412011539170.5721@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0412011539170.5721@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, linux-mm@vger.kernel.org, linux-kernel@vger.kernel.org

[Gerrit Huizenga, 2004-12-02 16:24:04]
> Towards that end, there
> was a recent effort at Bull on the NPTL work which serves as a very
> interesting model:

> http://nptl.bullopensource.org/Tests/results/run-browse.php

> Basically, you can compare results from any test run with any other
> and get a summary of differences.  That helps give a quick status
> check and helps you focus on the correct issues when tracking down
> defects.

Thanks Gerrit for mentioning this :)

Just an additional information -- the tool used to get this reporting
system is OSS and can be found here:
http://tslogparser.sourceforge.net

This tool is not mature yet, but it gives an overview of how useful a
test suite can be, when the results are easy to analyse...

It currently supports only the Open POSIX Test Suite, but I'd be happy
to work to enlarge the scope of this tool.

Regards, 
Seb.

PS: please include me in reply as I'm not subscribed to the list...
-------------------------------
Sebastien DECUGIS
NPTL Test & Trace Project
http://nptl.bullopensource.org/

"You may fail if you try.
You -will- fail if you don't."

