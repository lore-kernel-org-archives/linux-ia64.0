From: Grant Grundler <iod00d@hp.com>
Date: Fri, 06 Feb 2004 05:05:21 +0000
Subject: Re: q-tools-0.0 released
Message-Id: <20040206050521.GA4669@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040205215009.GA2316@cup.hp.com>
In-Reply-To: <20040205215009.GA2316@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Feb 05, 2004 at 02:57:22PM -0800, Stephane Eranian wrote:
> You need to have libpfm-3.0 installed on your system.
> I think Al Stone published the package on the Debian sites.
> You need the development + runtime packages.

Stephane,
Yes, he did.
Debian currently has:
ii  libpfm         2.0-6          IA-64 Performance Monitor (PMU) -- runt-time
ii  libpfm-dev     2.0-6          IA-64 Performance Monitor (PMU) -- developme
ii  pfmon          3.0-2          a performance monitoring tool for Linux/ia64

The pfmon from debian was probably built against "2.0-6" libpfm.
Is that bad?
I'll try this pfmon under 2.6 and see how that works.

> If you don't find the Debian package, then download:
> 
> 	ftp://ftp.hpl.hp.com/pub/linux-ia64/libpfm-3.0.tar.gz


"make install" default is "DESTDIR=/usr/local".
If I rebuild the pfmon package, it's unlikely to find that by default.

> Note that q-tools/libpfm-3.0/pfmon-3.0 ONLY work on 2.6 kernels.

yup - that's what I'm using here.

BTW, Once this is resolved,  someone will need to update the "README"
for q-tools or create a debian package for q-tools.

thanks,
grant
