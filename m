From: "Hartnett, Fred" <fred.hartnett@hp.com>
Date: Tue, 05 Mar 2013 23:05:00 +0000
Subject: CMCI vector not initialized on BP
Message-Id: <D8D957864D852146A97B866681B1DF2F0D16C73A@G9W0768.americas.hpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

smp_callin is responsible for initializing the CMC interrupt vector register for all APs, but the BP vector is not initialized since the BP is already online and therefore does not utilize smp_callin. The resulting behavior is the CMC interrupt on CPU0 is always masked as the vector value is 0x0 and TPR register is 0. Is this by design or an oops?

Thanks!
