From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 08 Jun 2004 18:02:37 +0000
Subject: Re: Scalability enhancements for gettimeofday
Message-Id: <16581.65341.778634.930936@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405201205.57930.clameter@sgi.com>
In-Reply-To: <200405201205.57930.clameter@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 8 Jun 2004 00:11:25 -0700 (PDT), Christoph Lameter <christoph@lameter.com> said:

  Christoph> How could this implementation put a bogus value into
  Christoph> last_itc?

The itc_get_offset() calculation depends on TIME_KEEPER->itm_next,
"jiffies" and "wall_jiffies", all of which are updated asynchronously
in response to a timer-interrupt.  If a timer-interrupt hits while
itc_get_offset() is running, the resulting value may have used
inconsistent values for those variables and hence could be bogus.

	--david
