From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 08 Jun 2004 04:33:02 +0000
Subject: Re: Scalability enhancements for gettimeofday
Message-Id: <16581.16766.391465.328756@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405201205.57930.clameter@sgi.com>
In-Reply-To: <200405201205.57930.clameter@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 7 Jun 2004 21:08:10 -0700 (PDT), Christoph Lameter <clameter@sgi.com> said:

  Christoph> Here is the patch with the use of cmpxchg to update
  Christoph> last_itc:

You're missing my point: if read_seqretry() causes a retry,
get_offset() better had NOT modified the global time-offset.

	--david
