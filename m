From: Grant Grundler <iod00d@hp.com>
Date: Thu, 15 May 2003 17:38:34 +0000
Subject: Re: [Linux-ia64] Parallel make
Message-Id: <marc-linux-ia64-105590723705835@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705774@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705774@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, May 15, 2003 at 09:59:29AM +1000, Martin Pool wrote:
> (Advertorial): Now you've got make -j4, you should try ccache and
> distcc. 

(Endorsement): Stephane and I played around with just distcc for
2.4 ia64 kernels on a smaller cluster of rx2600 (dual CPU).
The "master" runs out of CPU around -j16 (8 hosts).
But that resulted in 66 second kernel builds.
And distcc really is trivial to setup.

grant

