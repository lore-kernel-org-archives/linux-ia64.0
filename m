From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 07 Jun 2004 20:55:59 +0000
Subject: Re: Scalability enhancements for gettimeofday
Message-Id: <16580.54879.250269.131666@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405201205.57930.clameter@sgi.com>
In-Reply-To: <200405201205.57930.clameter@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 7 Jun 2004 13:24:45 -0700 (PDT), Christoph Lameter <clameter@sgi.com> said:

  Christoph> How would you like the following patch? It simply uses a
  Christoph> static variable to insure that the ITC value used in
  Christoph> get_offset never goes backward.

Eh, you need to worry about races.  There can be a timer-tick while
get_offset is running.

	--david
