From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 22 Oct 2004 10:50:02 +0000
Subject: Re: [patch 2.6.9] Avoid a rare deadlock during unwind
Message-Id: <16760.58842.41687.402151@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <9718.1098174005@kao2.melbourne.sgi.com>
In-Reply-To: <9718.1098174005@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 22 Oct 2004 20:14:26 +1000, Keith Owens <kaos@sgi.com> said:

  Keith> Ignore that, brain malfunction.  read/write_lock does not sleep.
  Keith> read_lock != semaphore.

Yup.

	--david
