From: Jes Sorensen <jes@wildopensource.com>
Date: Tue, 13 May 2003 00:41:03 +0000
Subject: [Linux-ia64] Re: 2.5.69 process.c: cpu_idle() cleanup
Message-Id: <marc-linux-ia64-105590723705744@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705738@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705738@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:

David> Is this a real need or is this just something hypothetical?  If
David> the latter, I'd rather leave what's there now.

Hi David,

The problem with the current code is that it doesn't work for generic
kernels and for the SN2 we really like to have this feature in place.
The PROM allows you to go in and look at the led status even if the
kernel has hung.

The other reason was that I was trying to get rid of SN specific
features from generic files and having a more generic API for this
seemed useful to me.

So to answer your question, yes I think there is a real use for this.

Cheers,
Jes

