From: Jes Sorensen <jes@sunsite.dk>
Date: Tue, 02 Oct 2001 14:28:50 +0000
Subject: Re: [Linux-ia64] [patch] quick combo patch relative to 2.4.10+010924 ia64 patch
Message-Id: <marc-linux-ia64-105590698805290@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805286@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805286@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@hpl.hp.com> writes:

David> Below is a quick patch which collects the various small fixes
David> that have been posted since the last kernel patch.

While in the patchy mood; for those who are interested in playing with
my QLA1280 patch, the latest version can be found at
http://www.wildopensource.com/~jes/linux - as of today, the latest
release is 3.23.10.

3.23.10 fixes a bug that may make the driver work on big endian boxes
again, but I don't have any PCI based big endian boxes here so I
cannot test it.

Check the changelog at the beginning of the file for details on all
the changes.

Cheers,
Jes

