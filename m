From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 02 Aug 2004 09:36:17 +0000
Subject: Re: Timer updates revision 7 (asm sets predicates/various fixes)
Message-Id: <16654.2833.511956.400488@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0407292044500.3633@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0407292044500.3633@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 30 Jul 2004 08:34:56 -0700 (PDT), Christoph Lameter <clameter@sgi.com> said:

  >> The numbers above indicate a substantial slowdown going from 1 to
  >> 2 cpus. What happens at higher cpu counts.

  Christoph> The code that uses cmpxchg will always be a scalability
  Christoph> issue.

Also, you need to keep things in perspective: the test programs
_continually_ bangs on gettimeofday().  If the cmpxchg were a
scalability issue for, say, 16-32-way machines with _real_ workloads,
I'd really be surprised.  Now if you have 128 or more CPUs, I do agree
that the picture would be very different and scalability is a much
bigger concern.

	--david
