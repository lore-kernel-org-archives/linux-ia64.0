From: Bdale Garbee <bdale@gag.com>
Date: Sat, 07 Jul 2001 11:22:31 +0000
Subject: Re: [Linux-ia64] SSL on Itanium Linux
Message-Id: <marc-linux-ia64-105590693005823@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005821@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005821@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

shameem.f.akhter@intel.com (Akhter, Shameem F) writes:

> I am looking for information about SSL on Linux. Could you please let me
> know, which flavor of SSL (it could be mod_SSL, OpenSSL, SSLeay) is
> available on Itanium Linux.

I am happily using OpenSSL on our Debian systems right now.  It required a
fairly trivial patch to the Configure file to define the compilation options
desired, which I am pretty sure has been merged in upstream by now.

Bdale

