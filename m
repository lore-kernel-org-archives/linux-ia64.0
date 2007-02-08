From: Keith Owens <kaos@sgi.com>
Date: Thu, 08 Feb 2007 06:04:30 +0000
Subject: Re: [RFC Patch]Use ar.kr2 for smp_processor_id
Message-Id: <6737.1170914670@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1170905324.3230.7.camel@linux-znh>
In-Reply-To: <1170905324.3230.7.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zou Nan hai (on 08 Feb 2007 11:28:44 +0800) wrote:
>Pin ar.kr2 of each CPU, so that smp_processor_id can use it.

Historically ar.k2 has been reserved for debugging purposes, for
example in ivt.S.  Debuggers often need a location that can be used to
track progress, it has to be somewhere that does not rely on TLB
entries and is guaranteed to appear in MCA/INIT records - ar.k2 is
perfect for this.

Use Tony's suggestion of testing for a change in ar.k3 (guaranteed to
be unique on every cpu) and caching the corresponding cpu number when
it changes.

