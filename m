From: alext@fc.hp.com (Alex Tsariounov)
Date: Mon, 27 Sep 2004 16:24:18 +0000
Subject: CPU utilization measurement tools/methods for network performance tests
Message-Id: <20040927162418.GA2524@fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello:

I am currently using netperf to measure performance of a couple of
network drivers on ia64/2.6.7 and am having a trying time measuring
CPU utilization.

Does anyone have a dependable tool or method to measure CPU
utilization, especially over a minute/two-minute-long measurement
interval?

I'd like to get a little more accurate and dependable result than just
eye-balling top for the run.  Also, something that does not interfere
with the test would be important.

The CPU utilization measurement methods provided by netperf produce
different results depending on which one is used and I'd like to use a
secondary method to confirm them.

Thank you,
Alex
