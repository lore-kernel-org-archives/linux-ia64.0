From: Mario Smarduch <cms063@email.mot.com>
Date: Tue, 16 Mar 2004 20:40:08 +0000
Subject: UCE and NUMA
Message-Id: <40576628.927DEB35@email.mot.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

we're currently evaluating a NUMA system (8-way). We're
wondering for hot contention spots does the 2.4 or 2.6 kernel
make use  of IA64   UCE Memory attribute (fetchadd)?
Has anyone been able to catpure relative performance
differences  (WB vs. UCE) for any benchmark ?

- Mario



