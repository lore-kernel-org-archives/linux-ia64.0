From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Fri, 16 Jul 2004 22:43:29 +0000
Subject: Re: problem with ski & NUE
Message-Id: <16632.23057.187943.381226@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040715133007.46413.qmail@web14205.mail.yahoo.com>
In-Reply-To: <20040715133007.46413.qmail@web14205.mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Daniele" = Daniele Velardi <leoaprilia@yahoo.com> writes:

Daniele> on my OS is already installed glibc 2.3.2 (suse 9.0)!  don't
Daniele> seem a problem!  For install the ski version 0.981 form the
Daniele> tar-ball, i have overwrite the file of directory NUE created
Daniele> form the last rpm's: ski 0.943 nue 1.1.1 nue fs 1.2 My
Daniele> installation procedure is correct?  Then for the system mode,

Please don't use nue --- it's very very old.  Ski from the current
download site should work fine, but you'll need to build yourself (or
get hold of somehow) a recent gcc and binutils built as cross
compilers.   The ones in the nue-fs are too old to build today's
kernels.   See http://gelato.unsw.edu.au/IA64wiki/CrossDevelopment for
more information,including how to build cross compilers etc -- use the
AlternateCrossCompilation link as you're using Suse not Debian.  Or
Dan Kegel's cross compilation building method at
http://kegel.com/crosstool/

--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
